params {
    step: Integer = 0
}


workflow{

    // Task 1 - Read in the samplesheet.

    if (params.step == 1) {
        channel.fromPath('../day_02/fetchngs_out/samplesheet/samplesheet.csv')
            .splitCsv(header: true, quote: '"')
            .view()
    }

    // Task 2 - Read in the samplesheet and create a meta-map with all metadata and another list with the filenames ([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
    //          Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

    if (params.step == 2) {
        in_ch = channel.fromPath('samplesheet.csv')
            .splitCsv(header: true, quote: '"')
            .map { row ->
                def meta  = row.findAll { k, v -> !(k in ['fastq_1', 'fastq_2']) }
                def reads = [row.fastq_1, row.fastq_2].findAll { f -> f }.collect { f -> file(f) }
                [meta, reads]
            }
        in_ch.view()
    }

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently. 
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

    if (params.step == 3) {
        
    }

    // Task 4 - Group together all files with the same sample-id and strandedness value.

    if (params.step == 4) {
        
    }



}