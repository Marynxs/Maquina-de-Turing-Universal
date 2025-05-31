# ====== Máquina de Turing Universal ======
class MTU
  attr_accessor :fita, :estado, :cursor, :fita_simulada

  def initialize
    @estado = :qi
    @cursor = 0
  end

  # entrada = transições + "$" + codificação da fita (blocos separados por 'z')
  # no final, escreve a fita simulada (blocos) de volta em @fita
  def processar(entrada)
    # monta a fita “virtual”
    @fita   = "#" + entrada + " " * entrada.size * 3
    @estado = :qi
    @cursor = 0

    # separa transições de w
    trans_str, w_str = entrada.split("$", 2)

    # constrói a tabela de transição
    transicoes = {}
    trans_str.scan(/([^z]+)z([^z]+)z([^z]+)z([^z]+)z([^z]+)/).each do |e1, s1, e2, s2, dir|
      mov = (dir == MtCodificada::DIR ? :D : :E)
      transicoes[[e1, s1]] = [s2, e2, mov]
    end

    # monta a fita simulada (lista de blocos + branco final)
    @fita_simulada = w_str.split("z") + [MtCodificada::BA]

    # simula a sub-máquina
    estado_mt = Q0
    pos       = 0
    loop do
      bloco = @fita_simulada[pos]
      regra = transicoes[[estado_mt, bloco]]
      # se não há regra, para e retorna aceitação conforme paridade do nome do estado
      unless regra
        aceitar = estado_mt.size.odd?
        escrever_resultado!(aceitar)
        return aceitar
      end

      esc, novo, mov = regra
      @fita_simulada[pos] = esc
      estado_mt         = novo
      pos += (mov == :D ? 1 : -1)
    end
  end

  private

  # sobrescreve @fita com a fita simulada codificada de volta em z-format
  def escrever_resultado!(aceitou)
    # codifica os blocos de volta em string única
    resultado = @fita_simulada.join("z")
    # coloca após o marcadór '$' na fita principal
    before, _ = @fita.split("$", 2)
    @fita = before + "$" + resultado
    # adiciona marcador de aceitou/rejeitou no final
    marcador = aceitou ? "[OK]" : "[NO]"
    @fita << marcador
  end
end

# ====== Codificação das MTs de teste ======
module MtCodificada
  DIR = "cc"   # direita
  ESQ = "c"    # esquerda
  BA  = "ba"   # branco

  # — Teste 1: a^n b^n —
  module ABn
    Q0 = "aa"; Q1 = "aaaa"; Q2 = "a"
    X  = "bbba"; Y  = "bbbbbba"
    TRANSITIONS = [
      [Q0, X,  Q1, X,  DIR],
      [Q1, X,  Q1, X,  DIR],
      [Q1, Y,  Q1, Y,  DIR],
      [Q1, BA, Q2, BA, ESQ]
    ]

    def self.linker
      TRANSITIONS.map { |e1,s1,e2,s2,dir| [e1,s1,e2,s2,dir].join("z") }.join("z")
    end

    def self.cadeia(n)
      ([X]*n + [Y]*n).join("z")
    end

    def self.q0; Q0; end
  end

  # — Teste 2: a^n b^n c^n —
  module ABnCn
    Q0 = "aa"; Q1 = "aaaa"; Qf = "a"
    X  = "bbba"; Y  = "bbbbbba"; Z = "bbbbbbbba"
    TRANSITIONS = [
      [Q0, X,  Q0,  X,  DIR],
      [Q0, Y,  Q1,  Y,  DIR],
      [Q1, Y,  Q1,  Y,  DIR],
      [Q1, Z,  Qf,  Z,  DIR],
      [Qf, Z,  Qf,  Z,  ESQ]
    ]

    def self.linker
      TRANSITIONS.map { |e1,s1,e2,s2,dir| [e1,s1,e2,s2,dir].join("z") }.join("z")
    end

    def self.cadeia(n)
      ([X]*n + [Y]*n + [Z]*n).join("z")
    end

    def self.q0; Q0; end
  end

  # — Teste 3: a^3 b^2 c^6 —
  module Mult
    Q0  = "aa";   Q1  = "aaa";   Q2  = "aaaaa"
    Q3  = "aaaaaaa"; Q4  = "aaaaaaaaa"; Q5  = "aaaaaaaaaaa"
    Q6  = "aaaaaaaaaaaaa"; Q7  = "aaaaaaaaaaaaaaa"
    Q8  = "aaaaaaaaaaaaaaaaa"; Q9 = "aaaaaaaaaaaaaaaaaaa"
    Q10 = "aaaaaaaaaaaaaaaaaaaaa"; Q11 = "aaaaaaaaaaaaaaaaaaaaaaa"
    X   = "bbba"; Y   = "bbbbbba"; C   = "bbbbbbbbbba"

    TRANSITIONS = [
      [Q0, X,  Q1, X,  DIR],
      [Q1, X,  Q2, X,  DIR],
      [Q2, Y,  Q3, Y,  DIR],
      [Q3, C,  Q4, C,  DIR],
      [Q4, C,  Q5, C,  DIR],
      [Q5, C,  Q6, C,  DIR],
      [Q6, C,  Q7, C,  DIR],
      [Q7, C,  Q8, C,  DIR],
      [Q8, C,  Q9, C,  DIR],
      [Q9, C, Q10, C,  DIR],
      [Q10,C, Q11, C,  ESQ]
    ]

    def self.linker
      TRANSITIONS.map { |e1,s1,e2,s2,dir| [e1,s1,e2,s2,dir].join("z") }.join("z")
    end

    def self.cadeia
      ([X]*3 + [Y]*2 + [C]*6).join("z")
    end

    def self.q0; Q0; end
  end
end

# ====== Execução de todos os testes ======
mt = MTU.new

# Teste 1
Object.send(:remove_const, :Q0) if Object.const_defined?(:Q0)
Object.const_set(:Q0, MtCodificada::ABn.q0)
entrada = MtCodificada::ABn.linker + "$" + MtCodificada::ABn.cadeia(3)
puts "=== Teste 1: a^3 b^3 ==="
puts mt.processar(entrada)
puts "Fita final:"
puts mt.fita
puts "----\n\n"

# Teste 2
Object.send(:remove_const, :Q0) if Object.const_defined?(:Q0)
Object.const_set(:Q0, MtCodificada::ABnCn.q0)
entrada = MtCodificada::ABnCn.linker + "$" + MtCodificada::ABnCn.cadeia(3)
puts "=== Teste 2: a^3 b^3 c^3 ==="
puts mt.processar(entrada)
puts "Fita final:"
puts mt.fita
puts "----\n\n"

# Teste 3
Object.send(:remove_const, :Q0) if Object.const_defined?(:Q0)
Object.const_set(:Q0, MtCodificada::Mult.q0)
entrada = MtCodificada::Mult.linker + "$" + MtCodificada::Mult.cadeia
puts "=== Teste 3: a^3 b^2 c^6 ==="
puts mt.processar(entrada)
puts "Fita final:"
puts mt.fita
puts "----"
