process QTLTOOLS_MBV {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::bioconductor-dupradar=1.18.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'naotokubota/qtltools:1.3.1'}"

    input:
    tuple val(meta), path(bam), path(bai)
    path (vcf)

    output:
    tuple val(meta), path("*.bamstat.txt"), emit: mbv_multiqc
    path "versions.yml"           , emit: versions
    
    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '1.3.1'

    """
    apt-get update && apt-get install samtools -y && \\
    samtools view -o ${bam}.qtl.bam $bam chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY && \\
    samtools index ${bam}.qtl.bam && \\
    QTLtools \\
        mbv \\
        --bam ${bam}.qtl.bam \\
        --vcf $vcf \\
        --out ${prefix}.bamstat.txt \\
        --filter-mapping-quality 15

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qtltools: ${VERSION}
    END_VERSIONS
    """
}
        // qtltools: \$(echo \$(qtltools 2>&1) | sed 's/^.*Version : //; s/qtltools.*\$//')
