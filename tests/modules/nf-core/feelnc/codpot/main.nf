#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { FEELNC_CODPOT } from '../../../../../modules/nf-core/feelnc/codpot/main.nf'

workflow test_feelnc_codpot {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    FEELNC_CODPOT ( input )
}
