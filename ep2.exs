# EP2
# Lógica Computacional

ExUnit.start()

###########################################################
# I. FUNÇÕES DESENVOLVIDAS
#
###########################################################

defmodule Grammar do
	# JOIN
	# Esta função realiza a junção U de duas listas
	# Verifica que a os elementos a serem adicionado 
	# não estão já presentes na lista final
	def join(list, [h | t]) do
		if h not in list do
			join(list ++ [h], t)
		else
			join(list, t)
		end
	end

	def join(list, []) do
		list
	end

	# TRAVERSE
	# Percorre RECURSIVAMENTE uma lista
	def traverse([h | t]) do
		IO.inspect(h)
		traverse(t)
	end
	
	def traverse([]) do
	end
	
	# GENERATE
	# Gera todos as cadeias de tamanho menor que size.
	def generate(sigma, n, p, s, size) do
		if onlyTerminals(s, n) do
			s
		else
			generate(sigma, n, p, applyRules(p, n, s, size, []), size)
		end
	end

	# ONLY_TERMINALS
	# Checa se na lista de cadeias [h | t] há apenas terminais
	def onlyTerminals([h | t], n) do
		if String.contains?(h, n) do
			false
		else
			onlyTerminals(t, n)
		end
	end
	
	def onlyTerminals([], _) do
		true
	end
	
	# SWAP_NT_TO_T
	# Percorre a cadeia str
	# Troca não terminais por terminais, 
	# levando em conta o tamanho máximo size permitido das cadeias
	def swapNTtoT(str, n, [h | t], size, newStr) do
		cond do
			String.contains?(str, n) == false -> # Checa se a cadeia é composta apenas por terminais. Em caso positivo, retorna a cadeia
				[str]
			String.length(str) - String.length(elem(h, 0)) + String.length(elem(h, 1)) < size and String.contains?(str, elem(h, 0)) -> # Só adiciona se o tamanho for menor e se o elemento da regra está contido na cadeia
				swapNTtoT(str, n, t, size, newStr ++ [String.replace(str, elem(h, 0), elem(h, 1))])
			true -> # Senão, vai para a próxima regra
				swapNTtoT(str, n, t, size, newStr)
		end
	end
	
	def swapNTtoT(_, _, [], _, newStr) do
		newStr
	end

	# APPLY_RULES
	# Aplica as regras P na lista [h | t]
	def applyRules(p, n, [h | t], size, newStrings) do
		applyRules(p, n, t, size, join(newStrings, swapNTtoT(h, n, p, size, [])))
	end
	
	def applyRules(_, _, [], _, newStrings) do
		newStrings
	end
	
	# CHECK_GRAMMAR
	# Checa se a cadeia pode ser criada pela gramática definida
	def checkGrammar(n, sigma, p, s, str) do
		if str in generate(sigma, n, p, s, String.length(str) + 1) do
			true
		else
			false
		end
	end

end

###########################################################
# II. CASOS DE TESTE
#
# Foram usados os exemplos apresentados em sala de aula
###########################################################

defmodule GrammarTest do
  use ExUnit.Case

# Gramática 1: gera cadeias do formato ab(ab)*
  test "G1-1" do 
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S"], ["a", "b"],[{"S", "ab"}, {"S", "abS"}], ["S"], "ababababab" ) == true
  end
  
  test "G1-2" do
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S"], ["a", "b"],[{"S", "ab"}, {"S", "abS"}], ["S"], "ababababbb" ) == false
  end

  test "G1-3" do
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S"], ["a", "b"],[{"S", "ab"}, {"S", "abS"}], ["S"], "ab" ) == true
  end
  
  test "G1-4" do
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S"], ["a", "b"],[{"S", "ab"}, {"S", "abS"}], ["S"], "" ) == false
  end
  
# Gramática 2: gera cadeias do formato (a^n)(b^n), n > 0
  test "G2-1" do 
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S"], ["a", "b"],[{"S", "ab"}, {"S", "aSb"}], ["S"], "aaabbb" ) == true
  end  

  test "G2-2" do 
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S"], ["a", "b"],[{"S", "ab"}, {"S", "aSb"}], ["S"], "aabbb" ) == false
  end  
  
  test "G2-3" do 
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S"], ["a", "b"],[{"S", "ab"}, {"S", "aSb"}], ["S"], "bbaa" ) == false
  end 

  test "G2-4" do 
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S"], ["a", "b"],[{"S", "ab"}, {"S", "aSb"}], ["S"], "" ) == false
  end    
  
# Gramática 3: gera cadeias do mesmo formato que a gramática anterior
  test "G3-1" do 
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S", "B"], ["a", "b"],[{"S", "aB"}, {"B", "Sb"}, {"B", "b"}], ["S"], "aaabbb" ) == true
  end 
  
  test "G3-2" do 
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S", "B"], ["a", "b"],[{"S", "aB"}, {"B", "Sb"}, {"B", "b"}], ["S"], "aaaab" ) == false
  end 
  
  test "G3-3" do 
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S", "B"], ["a", "b"],[{"S", "aB"}, {"B", "Sb"}, {"B", "b"}], ["S"], "" ) == false
  end 
  
# Gramática 4: gera cadeias do formato (a^n)(b^n)(c^n), n > 0
  test "G4-1" do 
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S", "B", "C"], ["a", "b", "c"], [{"S", "aBC"}, {"S", "aSBC"}, {"CB", "BC"}, {"aB", "ab"}, {"bB", "bb"}, {"bC", "bc"}, {"cC", "cc"}], ["S"], "aaabbbccc") == true
  end 
  
  test "G4-2" do 
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S", "B", "C"], ["a", "b", "c"], [{"S", "aBC"}, {"S", "aSBC"}, {"CB", "BC"}, {"aB", "ab"}, {"bB", "bb"}, {"bC", "bc"}, {"cC", "cc"}], ["S"], "abc") == true
  end 

  test "G4-3" do 
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S", "B", "C"], ["a", "b", "c"], [{"S", "aBC"}, {"S", "aSBC"}, {"CB", "BC"}, {"aB", "ab"}, {"bB", "bb"}, {"bC", "bc"}, {"cC", "cc"}], ["S"], "aaccbb") == false
  end 
  
  test "G4-4" do 
    require IEx
    IEx.pry()
    assert Grammar.checkGrammar(["S", "B", "C"], ["a", "b", "c"], [{"S", "aBC"}, {"S", "aSBC"}, {"CB", "BC"}, {"aB", "ab"}, {"bB", "bb"}, {"bC", "bc"}, {"cC", "cc"}], ["S"], "aaabbcc") == false
  end 
  
end

ExUnit.Server.modules_loaded()

ExUnit.run()
