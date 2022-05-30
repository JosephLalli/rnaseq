//
// Intron/splice site usage quantification with leafcutter
//

include { REGTOOLS_BAMTOJUNC        } from '../../modules/local/leafcutter/regtools_bamtojunc'
include { LEAFCUTTER_CLUSTERINTRONS } from '../../modules/local/leafcutter/leafcutter_cluster_introns'

workflow QUANTIFY_LEAFCUTTER {
    take:
    bam_sorted_indexed  // channel: [ val(meta), [ bam ], [ bai ] ]

    main:

    ch_versions = Channel.empty()

    //
    // extract splicing junctions from bam alignment
    //
    REGTOOLS_BAMTOJUNC( bam_sorted_indexed )
    ch_versions = ch_versions.mix(REGTOOLS_BAMTOJUNC.out.versions.first())
    
    junc_file_ch = REGTOOLS_BAMTOJUNC.out.junctions.map{it.toString()}.collectFile(name: 'leafcutter_junction_files.txt', newLine: true)

    LEAFCUTTER_CLUSTERINTRONS( junc_file_ch )
    ch_versions = ch_versions.mix(LEAFCUTTER_CLUSTERINTRONS.out.versions.first())
    
    emit:
    leafcutter_intron_counts = LEAFCUTTER_CLUSTERINTRONS.out.leafcutter_perind_counts       // channel: [ path(countsfile) ]
    
    versions                 = ch_versions 
}