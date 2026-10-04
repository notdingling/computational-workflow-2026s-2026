params {
    step: Integer = 0
}


workflow{

    // Samplesheet in this folder (sample, fastq_1, fastq_2, strandedness).
    // It is built for these tasks: three different strandedness values (Task 3)
    // and CONTROL_REP1 sequenced twice with the same strandedness (Task 4).
    def samplesheet = "${projectDir}/samplesheet.csv"

    // Task 1 - Read in the samplesheet.

    if (params.step == 1) {
        channel.fromPath(samplesheet)
            .splitCsv(header: true, quote: '"')
            .view()
    }

    // Task 2 - Read in the samplesheet and create a meta-map with all metadata and another list with the filenames ([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
    //          Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

    if (params.step == 2) {
        in_ch = channel.fromPath(samplesheet)
            .splitCsv(header: true, quote: '"')
            .map { row ->
                def meta  = row.findAll { k, v -> !(k in ['fastq_1', 'fastq_2']) }
                def reads = [row.fastq_1, row.fastq_2].findAll { f -> f }.collect { f -> file("${projectDir}/${f}") }
                [meta, reads]
            }
        in_ch.view()
    }

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently.
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

    if (params.step == 3) {
        in_ch = channel.fromPath(samplesheet)
            .splitCsv(header: true, quote: '"')
            .map { row ->
                def meta  = row.findAll { k, v -> !(k in ['fastq_1', 'fastq_2']) }
                def reads = [row.fastq_1, row.fastq_2].findAll { f -> f }.collect { f -> file("${projectDir}/${f}") }
                [meta, reads]
            }

        // nf-core/rnaseq accepts four strandedness values, so we need four channels.
        // Each element goes to the FIRST branch whose condition is true;
        // 'other' catches anything unexpected (e.g. a typo or a missing column).
        strand_ch = in_ch.branch { meta, reads ->
            auto:       meta.strandedness == 'auto'
            forward:    meta.strandedness == 'forward'
            reverse:    meta.strandedness == 'reverse'
            unstranded: meta.strandedness == 'unstranded'
            other:      true
        }

        // A prefix in each view() makes it clear which channel an element came from.
        strand_ch.auto.view       { v -> "[auto]       ${v}" }
        strand_ch.forward.view    { v -> "[forward]    ${v}" }
        strand_ch.reverse.view    { v -> "[reverse]    ${v}" }
        strand_ch.unstranded.view { v -> "[unstranded] ${v}" }
        strand_ch.other.view      { v -> "[other]      ${v}" }
    }

    // Task 4 - Group together all files with the same sample-id and strandedness value.

    if (params.step == 4) {
        in_ch = channel.fromPath(samplesheet)
            .splitCsv(header: true, quote: '"')
            .map { row ->
                def meta  = row.findAll { k, v -> !(k in ['fastq_1', 'fastq_2']) }
                def reads = [row.fastq_1, row.fastq_2].findAll { f -> f }.collect { f -> file("${projectDir}/${f}") }
                [meta, reads]
            }

        // groupTuple() groups by the FIRST element of each tuple.
        // Build an explicit key of only sample id + strandedness, so any extra
        // per-run metadata columns in the samplesheet wouldn't prevent grouping.
        grouped_ch = in_ch
            .map { meta, reads -> [[id: meta.sample, strandedness: meta.strandedness], reads] }
            .groupTuple()
            // groupTuple gives [[r1, r2], [r1, r2], ...] -> flatten to one list of files
            .map { key, reads -> [key, reads.flatten()] }

        grouped_ch.view()
    }

}