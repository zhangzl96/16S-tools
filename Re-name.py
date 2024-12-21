def read_idmap(idmap_file):
    idmap = {}
    with open(idmap_file, 'r') as file:
        for line in file:
            old_id, new_id = line.strip().split()
            idmap[old_id] = new_id
    return idmap

def replace_ids_in_fasta(fasta_file, idmap, output_file):
    with open(fasta_file, 'r') as infile, open(output_file, 'w') as outfile:
        current_id = None
        for line in infile:
            if line.startswith('>'):
                # This is a header line
                current_id = line[1:].strip()
                if current_id in idmap:
                    new_id = idmap[current_id]
                    outfile.write(f'>{new_id}\n')
                else:
                    outfile.write(line)
            else:
                # This is a sequence line
                outfile.write(line)

if __name__ == "__main__":
    fasta_file = 'rarefied_seqs.fasta'
    idmap_file = 'id_map.txt'
    output_file = 'final_sequences.fasta'
    
    idmap = read_idmap(idmap_file)
    replace_ids_in_fasta(fasta_file, idmap, output_file)
    
    print(f"IDs have been replaced and the output is saved in {output_file}")
