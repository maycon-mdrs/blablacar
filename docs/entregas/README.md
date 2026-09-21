# Entregas — MACHINE abstrata (ProB)

Documentação incremental da especificação B do sistema de caronas. O artefato executável é [`Blablacar.mch`](../../Blablacar.mch); cada entrega descreve o **range** do [README](../../README.md) coberto e o que entra no modelo.

## Índice

| Entrega | Documento | Range (README) | Status do modelo |
|---------|-----------|----------------|------------------|
| **E1** | [01-usuarios-criar-viagem.md](01-usuarios-criar-viagem.md) | §§1–2 | Esqueleto no `.mch` (ops com `skip`) |
| **E2** | [02-pedido-aceitar-recusar.md](02-pedido-aceitar-recusar.md) | §§3–4 | Outline |
| **E3** | [03-cancelamentos.md](03-cancelamentos.md) | §5 | Outline |
| **E4** | [04-iniciar-concluir-consultas.md](04-iniciar-concluir-consultas.md) | §§6–9 | Outline |

## Template de documento de entrega

Cada arquivo `0N-nome.md` segue esta estrutura:

1. **Range** — seções do README cobertas
2. **SETS / CONSTANTS** — tipos e constantes desta entrega
3. **VARIABLES** — estado novo
4. **INVARIANT** — invariantes do range (texto + B)
5. **OPERATIONS** — assinatura e pré-condições; corpo `skip` enquanto abstrato
6. **Fora de escopo** — o que fica para a próxima entrega
7. **Checklist ProB** — o que animar / checar nesta entrega

## Convenção do esqueleto B

Nesta fase as operações têm apenas pré-condições; o corpo permanece `skip`:

```
op_name(params) =
  PRE
    /* guards */
  THEN
    skip
  END
```

Corpos (`THEN` com atribuições) entram em entregas posteriores, quando o estado correspondente estiver modelado.
