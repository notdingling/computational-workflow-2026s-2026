#!/usr/bin/env nextflow

process SPLITLETTERS {
    input:
        tuple val(meta), val(in_str), val(out_name)
    output:
        tuple val(meta), path("${out_name}_*")
    script:
    // printf (not echo) so no trailing newline ends up as an extra character in the last chunk.
    // split -b <n> writes chunks named <prefix>_aa, <prefix>_ab, ...
    """
    printf '%s' "${in_str}" | split -b ${meta.block_size} - ${out_name}_
    """
}

process CONVERTTOUPPER {
    debug true
    publishDir 'results', mode: 'copy'

    input:
        path chunk
    output:
        path "upper_${chunk}"
    script:
    """
    tr '[:lower:]' '[:upper:]' < ${chunk} > upper_${chunk}
    cat upper_${chunk}
    echo
    """
}

workflow {
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet
    in_ch = channel.fromPath("${projectDir}/samplesheet_2.csv")
        .splitCsv(header: true)
        .map { row -> [[block_size: row.block_size as Integer], row.input_str, row.out_name] }

    // split the input string into chunks
    chunks_ch = SPLITLETTERS(in_ch)
    chunks_ch.view { meta, files -> "chunks (block_size=${meta.block_size}): ${files}" }

    // lets remove the metamap to make it easier for us, as we won't need it anymore
    // flatten() emits every chunk file as its own element -> one CONVERTTOUPPER task per chunk
    files_ch = chunks_ch
        .map { meta, files -> files }
        .flatten()

    // convert the chunks to uppercase and save the files to the results directory
    CONVERTTOUPPER(files_ch)
}
