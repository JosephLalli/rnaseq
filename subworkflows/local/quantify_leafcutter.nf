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
    // I produce a list of 'HSB597.leafcutter.junc' (Which should actually be HSB597.junc)
    // but the filenames in the working dir of leafcutter are 1.junc.
    // Best way to collect files and meta data?
    REGTOOLS_BAMTOJUNC( bam_sorted_indexed )
    ch_versions = ch_versions.mix(REGTOOLS_BAMTOJUNC.out.versions.first())

    junc_files_ch = REGTOOLS_BAMTOJUNC.out.junctions.collect().view()
    junc_files_list_ch = REGTOOLS_BAMTOJUNC.out.junctions.map({it.toString()}).collectFile(name:'input_files.txt', newLine:true).view()
                //    .map{ it[1].toString() }
                //    .collectFile(name: 'junction_files.txt', newLine: true)
                //    .subscribe { println "Entries are saved to file: $it" }
    // junc_file_ch.view()

        //
    // once all are done, run fucntion to cluster 
    //


    // LEAFCUTTER_CLUSTERINTRONS( REGTOOLS_BAMTOJUNC.out.junctions.collect() )
    LEAFCUTTER_CLUSTERINTRONS( junc_files_ch, junc_files_list_ch )
    ch_versions = ch_versions.mix(LEAFCUTTER_CLUSTERINTRONS.out.versions)
    
    emit:
    leafcutter_intron_counts = LEAFCUTTER_CLUSTERINTRONS.out.leafcutter_perind_counts       // channel: [ path(countsfile) ]
    
    versions                 = ch_versions 
}