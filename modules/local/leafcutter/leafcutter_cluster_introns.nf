process LEAFCUTTER_CLUSTERINTRONS {
    tag "cluster_juncfiles"
    label 'process_medium'

    conda (params.enable_conda ? "python=3.9" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'quay.io/biocontainers/python:3.9--1'}"

    input:  
    path ('*.junc')
    path ('input_files.txt')
    // path joined_leafcutter_file from 

    output:
    path "leafcutter_perind*.gz", emit: leafcutter_perind_counts
    path "versions.yml"         , emit: versions
    
    when:
    task.ext.when == null || task.ext.when

    script:
    """
    leafcutter_cluster_regtools \\
        --juncfiles input_files.txt \\
        -o leafcutter \\
    && \\
    zcat leafcutter_perind_numers.counts.gz | \\
    sed 's/^/phenotype_id /' | \\
    sed 's/.sorted//g' | \\
    sed -e 's/ /\t/g' | \\
    gzip -c > leafcutter_perind_numers.counts.formatted.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        leafcutter: \$(echo \$(leafcutter_cluster_regtools --version 2>&1))
    END_VERSIONS
    """

    // """
    // ls
    // echo *.junc
    // echo *.junc | tr ' ' '\n' > list_of_junc_files.txt && \\
    // leafcutter_cluster_regtools \\
    //     --juncfiles list_of_junc_files.txt \\
    //     -o leafcutter \\
    // \\
    // && \\
    // gcat leafcutter_perind_numers.counts.gz | \\
    // sed 's/^/phenotype_id /' | \\
    // sed 's/.sorted//g' | \\
    // sed -e 's/ /\t/g' | \\
    // gzip -c > leafcutter_perind_numers.counts.formatted.gz

    // cat <<-END_VERSIONS > versions.yml
    // "${task.process}":
    //     leafcutter: \$(echo \$(leafcutter_cluster_regtools --version 2>&1))
    // END_VERSIONS
    // """
}