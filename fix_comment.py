p = open(r"e:\implement_Moodle\terraform\modules\compute\user_data.sh", encoding="utf-8")
t = p.read()
p.close()
old = "# O templatefile() substitui ${var} antes que o script rode na EC2."
new = "# O templatefile() processa as interpolacoes antes que o script rode na EC2."
if old in t:
    t = t.replace(old, new, 1)
    open(r"e:\implement_Moodle\terraform\modules\compute\user_data.sh", "w", encoding="utf-8").write(t)
    print("OK: comentario corrigido")
else:
    print("ERRO: padrao nao encontrado — mostrando linha 56-60:")
    for i, l in enumerate(t.splitlines()[55:61], 56):
        print(i, repr(l))
