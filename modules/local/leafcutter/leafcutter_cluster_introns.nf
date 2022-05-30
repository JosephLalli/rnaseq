process LEAFCUTTER_CLUSTERINTRONS {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "python=3.9" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'python:3.9-slim'}"

    input:  
    path(junc_file)

    output:
    path "leafcutter_perind*.gz", emit: leafcutter_perind_counts
    path "versions.yml"         , emit: versions
    
    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    leafcutter_cluster_regtools.py \\
        --juncfiles $junc_file \\
        -o leafcutter_perind_numers \\
        --checkchrom=True 
    
    zcat leafcutter_perind_numers.counts.gz | \\
    sed '1s/^/phenotype_id /' | \\
    sed 's/.sorted//g' | \\
    sed -e 's/ /\t/g' | \\
    gzip -c > leafcutter_perind_numers.counts.formatted.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        leafcutter: \$(echo \$(leafcutter_cluster_regtools --version 2>&1))
    END_VERSIONS
    """
}