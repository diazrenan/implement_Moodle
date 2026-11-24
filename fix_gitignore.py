p = open(r'e:\implement_Moodle\.gitignore', encoding='utf-8')
t = p.read()
p.close()

marker = '# Terraform'
idx = t.find(marker)
if idx == -1:
    print('ERRO: secao Terraform nao encontrada')
else:
    # Encontrar fim da linha do comentario Terraform
    end_of_line = t.index('\n', idx)
    # Inserir .terraform/ na linha seguinte ao comentario
    insert = '\n# Diretorio de plugins e cache do Terraform (gerado pelo terraform init)\n.terraform/'
    t = t[:end_of_line] + insert + t[end_of_line:]
    open(r'e:\implement_Moodle\.gitignore', 'w', encoding='utf-8').write(t)
    print('OK: .terraform/ adicionado apos secao Terraform')