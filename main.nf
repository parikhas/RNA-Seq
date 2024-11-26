#!/usr/bin/nextflow
nextflow.enable.dsl=2

// Genome Indexing module
process PREPARE_GMAP_DATABASE {
    container 'quay.io/biocontainers/gmap:2021.05.28--pl5321h9f5acd7_0'
    publishDir "${params.output_dir}/genome_index", mode: 'copy'

    input:
    path ref_genome

    output:
    path "${params.genome_name}", emit: gmap_index
    
    script:
    """
    # Create directory for genome index
    mkdir -p ${params.genome_name}
    
    # Build GMAP genome database
    gmap_build -d ${params.genome_name} \
               -D . \
               ${ref_genome}
    """
}

// Intron Index module
process PREPARE_INTRON_INDEX {
    container 'quay.io/biocontainers/gmap:2021.05.28--pl5321h9f5acd7_0'
    publishDir "${params.output_dir}/intron_index", mode: 'copy'

    input:
    path ref_annotation

    output:
    path "introns.iit", emit: intron_index
    
    script:
    """
    # Convert GTF to intron file
    gtf_introns.pl ${ref_annotation} > introns.gff

    # Create intron index
    iit_store -o introns.iit introns.gff
    """
}

// Trimmomatic module
process TRIMMOMATIC {
    container 'quay.io/biocontainers/trimmomatic:0.39--hdfd78af_2'
    publishDir "${params.output_dir}/trimmed_reads", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_trimmed_R1.fastq.gz"), path("${sample_id}_trimmed_R2.fastq.gz"), emit: trimmed_reads

    script:
    """
    trimmomatic PE -phred33 \
        ${reads[0]} ${reads[1]} \
        ${sample_id}_trimmed_R1.fastq.gz ${sample_id}_unpaired_R1.fastq.gz \
        ${sample_id}_trimmed_R2.fastq.gz ${sample_id}_unpaired_R2.fastq.gz \
        LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    """
}


// GSNAP alignment module
process GSNAP_ALIGNMENT {
    container 'quay.io/biocontainers/gmap:2021.05.28--pl5321h9f5acd7_0'
    publishDir "${params.output_dir}/sam_alignments", mode: 'copy'

    input:
    tuple val(sample_id), path(trimmed_r1), path(trimmed_r2)
    path gmap_index
    path intron_index

    output:
    tuple val(sample_id), path("${sample_id}.sam"), emit: sam_files

    script:
    """
    gsnap -d ${params.genome_name} -D . \
          -A sam \
          -N 1 \
          -m 0 \
          -i 50 \
          --intronpairs=1 \
          -w 50 \
          -E ${intron_index} \
          ${trimmed_r1} ${trimmed_r2} > ${sample_id}.sam
    """
}

// SAM to BAM conversion module
process SAM_TO_BAM {
    container 'quay.io/biocontainers/samtools:1.16.1--h6899075_1'
    publishDir "${params.output_dir}/alignments", mode: 'copy'

    input:
    tuple val(sample_id), path(sam_file)

    output:
    path "${sample_id}.bam", emit: bam_files
    path "${sample_id}.bam.bai", emit: bam_index

    script:
    """
    samtools view -Sb ${sam_file} > ${sample_id}.bam
    samtools index ${sample_id}.bam
    """
}

// Merge BAM files module (remains the same)
process MERGE_BAM {
    container 'quay.io/biocontainers/samtools:1.16.1--h6899075_1'
    publishDir "${params.output_dir}/merged_alignments", mode: 'copy'

    input:
    path bam_files

    output:
    path "merged.bam", emit: merged_bam
    path "merged.bam.bai", emit: merged_bam_index

    script:
    """
    samtools merge merged.bam ${bam_files}
    samtools index merged.bam
    """
}

// Trinity transcriptome assembly module
process TRINITY_ASSEMBLY {
    container 'quay.io/biocontainers/trinity:2.15.1--pl5321hdfd78af_0'
    publishDir "${params.output_dir}/trinity", mode: 'copy'

    input:
    path merged_bam

    output:
    path "Trinity.fasta", emit: assembly
    path "trinity_output", emit: output_dir

    script:
    """
    Trinity --genome_guided_bam ${merged_bam} \
            --genome_guided_max_intron 10000 \
            --max_memory 50G \
            --CPU ${params.threads} \
            --output trinity_output
    
    mv trinity_output/Trinity-GG.fasta Trinity.fasta
    """
}

// Transdecoder module
process TRANSDECODER {
    container 'quay.io/biocontainers/transdecoder:5.7.1--pl5321hdfd78af_0'
    publishDir "${params.output_dir}/transdecoder", mode: 'copy'

    input:
    path trinity_assembly

    output:
    path "*.pep", emit: proteins
    path "*.bed", emit: bed_files

    script:
    """
    TransDecoder.LongOrfs -t ${trinity_assembly}
    TransDecoder.Predict -t ${trinity_assembly}
    """
}

// InterProScan module
process INTERPROSCAN {
    container 'quay.io/biocontainers/interproscan:5.60--hb10bf35_0'
    publishDir "${params.output_dir}/interproscan", mode: 'copy'

    input:
    path proteins

    output:
    path "interproscan_results.tsv", emit: results

    script:
    """
    interproscan.sh -i ${proteins} \
                    -f TSV \
                    -o interproscan_results.tsv \
                    -t p \
                    -cpu ${params.threads}
    """
}

// BLAST2GO module
process BLAST2GO {
    container 'quay.io/biocontainers/blast2go:1.0--0'
    publishDir "${params.output_dir}/blast2go", mode: 'copy'

    input:
    path interproscan_results
    path trinity_assembly

    output:
    path "functional_annotation.txt", emit: annotations

    script:
    """
    # Perform BLAST against nr database
    blastp -query ${trinity_assembly} \
           -db nr \
           -out blast_results.txt \
           -evalue 1e-3 \
           -outfmt 6

    # Run Blast2GO analysis
    b2g4pipe -in blast_results.txt \
             -out functional_annotation.txt \
             -prop blast2go.properties
    """
}

// Genome Preparation workflow
workflow GENOME_PREPARATION {
    main:
        // Prepare GMAP genome database
        PREPARE_GMAP_DATABASE(params.ref_genome)
        
        // Prepare intron index
        PREPARE_INTRON_INDEX(params.ref_annotation)
}

// Main workflow
workflow RNA_SEQ_PIPELINE {
    main:
        // Genome preparation
        GENOME_PREPARATION()

        // Create input channel for read pairs
        read_ch = Channel
            .fromFilePairs(params.input_reads)
            .ifEmpty { error "Cannot find any reads matching: ${params.input_reads}" }

        // Trimming
        TRIMMOMATIC(read_ch)
        
        // Alignment
        GSNAP_ALIGNMENT(
            TRIMMOMATIC.out.trimmed_reads, 
            GENOME_PREPARATION.out.PREPARE_GMAP_DATABASE.gmap_index,
            GENOME_PREPARATION.out.PREPARE_INTRON_INDEX.intron_index
        )
        // Convert SAM to BAM
        SAM_TO_BAM(GSNAP_ALIGNMENT.out.sam_files)
        
        // Merge BAM files
        MERGE_BAM(GSNAP_ALIGNMENT.out.bam_files.collect())
        
        // Transcriptome Assembly
        TRINITY_ASSEMBLY(MERGE_BAM.out.merged_bam)
        
        // Protein Prediction
        TRANSDECODER(TRINITY_ASSEMBLY.out.assembly)
        
        // Protein Annotation
        INTERPROSCAN(TRANSDECODER.out.proteins)
        
        // Functional Annotation
        BLAST2GO(
            INTERPROSCAN.out.results, 
            TRINITY_ASSEMBLY.out.assembly
        )
}

// Run the pipeline
workflow {
    RNA_SEQ_PIPELINE()
}

// Workflow completion hook
workflow.onComplete {
    log.info "Pipeline completed successfully!"
    log.info "Output directory: ${params.output_dir}"
}