# 🧠 Máquina de Turing Universal (MTU) em Ruby

Este repositório contém uma implementação em Ruby de uma Máquina de Turing Universal capaz de simular outras Máquinas de Turing, incluindo linguagens livres de contexto, sensíveis ao contexto e operações aritméticas simples como multiplicação por codificação de estados e símbolos.

## 📚 Conceito

A Máquina de Turing Universal (MTU), proposta por Alan Turing em 1936, é uma máquina capaz de simular qualquer outra Máquina de Turing a partir de sua codificação. Neste projeto, a entrada da MTU é composta por duas partes:

1. **Codificação da máquina M** (em blocos separados por `z`)
2. **Codificação da fita de entrada** (`w`) da máquina M

Ao processar essa entrada, a MTU simula o comportamento da máquina M sobre a entrada `w`.

## 🧩 Codificação

Para permitir a simulação genérica, utilizamos um sistema de codificação com símbolos padronizados:

- **Estados não finais**: `"a"`, `"aa"`, `"aaa"`, ...
- **Estados finais (aceitação)**: `"aaaa"`, `"aaaaa"`, ...
- **Símbolos da fita**: `"bbba"`, `"bbbbbba"`, `"bbbbbbbba"`, ...
- **Movimentos**:
  - Direita: `"cc"`
  - Esquerda: `"c"`
- **Símbolo branco**: `"ba"`

A transição `(q, s) → (q’, s’, D)` é codificada como:
qzszq’zs’zcc
E as transições são concatenadas usando o separador `z`.

A fita de entrada também é codificada em blocos com `z`.

### 🔠 Exemplo de Entrada Codificada

Para reconhecer a linguagem `a* b+`, a MT seria codificada assim:

- Estados:
  - Inicial: `fa`
  - Final (aceitação): `fb`

- Símbolos:
  - `a`: `sc`
  - `b`: `scc`

- Regras:
  fascfascd
  fasccfbsccd
  fbsccfbsccd

- Entrada: `aabbb` → codificada como: `scscsccsccscc`

- Cadeia completa:
  fascfascdfasccfbsccdfbsccfbsccd#scscsccsccscc

## 🧪 Testes Inclusos

Três testes ilustram a flexibilidade e o poder da MTU:

### ✔️ Teste 1: Linguagem Livre de Contexto `aⁿ bⁿ`

Simula uma MT que reconhece cadeias balanceadas com o mesmo número de `a`s e `b`s.  
**Exemplo de entrada aceita:** `aaabbb`

### ✔️ Teste 2: Linguagem Sensível ao Contexto `aⁿ bⁿ cⁿ`

Simula uma MT que aceita cadeias com igual número de `a`s, `b`s e `c`s.  
**Exemplo de entrada aceita:** `aaabbbccc`

### ✔️ Teste 3: Multiplicação `aⁿ bᵐ → c⁽ⁿˣᵐ⁾`

Simula uma MT que, ao receber `n` símbolos `a` e `m` símbolos `b`, produz `n × m` símbolos `c`.  
**Exemplo de entrada:** `aaabb` → **saída esperada:** `cccccc`

## ⚙️ Execução

A simulação pode ser executada diretamente no terminal com o Ruby instalado:

```bash
ruby main.rb
```

O script irá imprimir no terminal:

- ✅ O resultado (true/false)
- 📄 A fita final com os símbolos codificados
- 🏁 O marcador `[OK]` (aceitação) ou `[NO]` (rejeição)

## 🧠 Teoria Aplicada

Este projeto demonstra, na prática, a definição da linguagem das Máquinas de Turing Universal:
L = { C(M)w ∈ Σ* | w ∈ L(M) }

Ou seja, o conjunto das cadeias formadas por uma codificação de uma Máquina de Turing `C(M)` seguida da cadeia de entrada `w`, tal que `w` é aceita por `M`.

Utilizando esse modelo, é possível representar e simular linguagens recursivamente enumeráveis e, assim, entender os limites computacionais dos modelos formais.
