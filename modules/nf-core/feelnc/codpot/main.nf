process FEELNC_CODPOT {
  conda (params.enable_conda ? "bioconda::feelnc=0.2" : null)
  container "${ workflow.containerEngine == 'singularity' ? 
                'https://depot.galaxyproject.org/singularity/feelnc:0.2--pl526_0' : 
                'quay.io/biocontainers/feelnc:0.2--pl526_0' }"
  memory params.maxMemory

  input:
  tuple val(meta), path(infile), path(mrna), path(lncrna)
  path(reference)

  output:
  tuple val(meta), path("feelnc_codpot_out/*.lncRNA.gtf"), emit: lncRNA
  tuple val(meta), path("feelnc_codpot_out/*.mRNA.gtf"), emit: mRNA

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  grep "protein_coding" ${ref} > known_mRNA.gtf
  grep -v "protein_coding" ${ref} > known_lncRNA.gtf

  # Source when using a container
  if [ -f "/usr/local/etc/conda/activate.d/feelnc-env.sh" ]; then
    source "/usr/local/etc/conda/activate.d/feelnc-env.sh"
  fi

  FEELnc_codpot.pl \
      -i ${infile} \
      -g ${reference} \
      -a known_mRNA.gtf \
      -l known_lncRNA.gtf \
      --numtx=3000,3000 \
      -o new
  
  # consider new noORF transcripts as new lncRNA
  if [ -e feelnc_codpot_out/new.noORF.gtf ]; then
    cat feelnc_codpot_out/new.noORF.gtf >> feelnc_codpot_out/new.lncRNA.gtf
  fi
  """
}