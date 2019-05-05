# EP3
# Lógica Computacional

ExUnit.start()

###########################################################
# I. FUNÇÕES DESENVOLVIDAS								  #
###########################################################

defmodule Automata do

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

# Parte 1: Autômato Finito Determinístico
	
	# FUNÇÃO PRINCIPAL
	
	# runFDA
	# ENTRADAS
	# input [inputHead | inputTail]: palavra de entrada. Ex.: ["a", "b", "a", "a"]
	# state: estado atual
	# finalStates: lista de estados finais de aceitação
	# transitions: lista de transições possíveis. Ex.: {[a, "q0", "q1"], [b, "q1", "q0"]}
	# SAÍDAS
	# true se cadeia aceita / false caso contrário
	
	def runFDA([inputHead | inputTail], state, finalStates, transitions) do
		cond do
		nextState(inputHead, state, transitions) != nil ->
			runFDA(inputTail, nextState(inputHead, state, transitions), finalStates, transitions)
		true -> false # rejeita pois não há transição para inputHead
		end
	end

	def runFDA([], state, finalStates, _) do
		acceptState?(state, finalStates)
	end
	
	# FUNÇÕES AUXILIARES

	def nextState(input, state, [transitionsHead | transitionsTail]) do
		cond do
		elem(transitionsHead, 0) == input && elem(transitionsHead, 1) == state -> 
			elem(transitionsHead, 2)
		true -> nextState(input, state, transitionsTail)
		end
	end
	
	def nextState(_, _, []) do
		nil
	end
	
	def acceptState?(state, [h | t]) do
		cond do
		state == h -> true
		true -> acceptState?(state, t)
		end
	end
	
	def acceptState?(_, []) do
		false
	end

# Parte 2 : Autômato Finito Não Determinístico
	
	# runNFDA
	# ENTRADAS
	# input [inputHead | inputTail]: palavra de entrada. Ex.: ["a", "b", "a", "a"]
	# state: estado atual
	# finalStates: lista de estados finais de aceitação
	# transitions: lista de transições possíveis. Ex.: {[a, "q0", "q1"], [b, "q1", "q0"]}
	# SAÍDAS
	# true se cadeia aceita / false caso contrário
	
	def runFNDA(input, state, finalStates, transitions) do
		checkIfContainsAnyElement(finalStates, getPossibleFinalStates([{input, state}], transitions, [], transitions, []))
	end
	
	# FUNÇÕES AUXILIARES
	
	def checkIfContainsAnyElement(finalStates, [h | t]) do
		cond do
		Enum.member?(finalStates, h) -> true
		true -> checkIfContainsAnyElement(finalStates, t)
		end
	end
	
	def checkIfContainsAnyElement(_, []) do
		false
	end
	
	# getPossibleFinalStates
	# Obtém todos os estados finais possíveis a partir de uma entrada composta por:
	# [reachableStatesHead | reachableStatesTail]: uma lista de tuplas de cadeias (lista) e estado (string)
	# [transitionsHead | transitionsTail]: transições a serem percorridas
	# newReachableStates: novas tuplas obtidas a partir das transições percorridas
	# transitions: lista de transições
	# endStates: estados finais obtidos ---> SAÍDA FINAL
	
	def getPossibleFinalStates([reachableStatesHead | reachableStatesTail], [transitionsHead | transitionsTail], newReachableStates, transitions, endStates) do
		cond do
			elem(reachableStatesHead, 0) == [] -> # Cadeia vazia: guardar estado atual na lista de estados finais
				getPossibleFinalStates(reachableStatesTail, transitions, [], transitions, join(endStates, [elem(reachableStatesHead, 1)]))
				
			elem(reachableStatesHead, 1) == elem(transitionsHead, 1) &&  elem(transitionsHead, 0) == "" -> # Estado atual possui transição Epsilon: adiciona resultado da transição  na lista de estados
				getPossibleFinalStates([reachableStatesHead | reachableStatesTail], transitionsTail, join(newReachableStates, [{elem(reachableStatesHead, 0), elem(transitionsHead, 2)}]), transitions, endStates)		
				
			elem(reachableStatesHead, 1) == elem(transitionsHead, 1) && getHead(elem(reachableStatesHead, 0)) == elem(transitionsHead, 0) -> # Transição compatível: adiciona resultado da transição na lista de estados
				getPossibleFinalStates([reachableStatesHead | reachableStatesTail], transitionsTail, join(newReachableStates, [{removeHead(elem(reachableStatesHead, 0)), elem(transitionsHead, 2)}]), transitions, endStates)

			true -> # Demais casos: continua a percorrer lista de transições
				getPossibleFinalStates([reachableStatesHead | reachableStatesTail], transitionsTail, newReachableStates, transitions, endStates)
		end
	end
	
	def getPossibleFinalStates([_ | reachableStatesTail], [], newReachableStates, transitions, endStates) do 
	# Terminou de percorrer lista de transições: percorre próximo elemento da lista de estados
		getPossibleFinalStates(join(reachableStatesTail, newReachableStates), transitions, [], transitions, endStates)
	end
	
	def getPossibleFinalStates([], _, _, _, endStates) do
	# Não há mais estados a serem analizados: retorna estados finais obtidos
		endStates
	end
	
	def removeHead([_ | t]) do
		t
	end
	
	def getHead([h | _]) do
		h
	end
end


###########################################################
# II. CASOS DE TESTE									  #
###########################################################

defmodule AutomataTest do
  use ExUnit.Case

  test "FDA1" do 
    require IEx    
    assert Automata.runFDA(["a", "b", "a", "a"], "q0", ["q1"], [{"a", "q0", "q1"}, {"a", "q1", "q1"}, {"b", "q1", "q0"}]) == true
  end  
  
  test "FDA2" do 
    require IEx    
    assert Automata.runFDA(["a", "b", "a", "a"], "q0", ["q0"], [{"a", "q0", "q1"}, {"a", "q1", "q1"}, {"b", "q1", "q0"}]) == false
  end 
  
  # Caractere inválido
  test "FDA3" do 
    require IEx    
    assert Automata.runFDA(["a", "c", "a", "a"], "q0", ["q0", "q1", "q2"], [{"a", "q0", "q1"}, {"a", "q1", "q1"}, {"b", "q1", "q0"}]) == false
  end 
  
  test "FDA4" do 
    require IEx    
    assert Automata.runFDA(["a", "b", "a", "a"], "q0", ["q0"], [{"a", "q0", "q1"}, {"a", "q1", "q1"}, {"b", "q1", "q0"}]) == false
  end 
  
  # DFA Costas Busch, slide 52
  # Aceita cadeias que contenham 001
  test "FDA5" do 
    require IEx    
    assert Automata.runFDA(["1", "0", "1", "0", "0", "0", "1", "0", "1"], "lambda", ["001"], [{"1", "lambda", "lambda"}, {"0", "lambda", "0"}, {"1", "0", "lambda"}, {"0", "0", "00"}, {"0", "00", "00"}, {"1", "00", "001"}, {"1", "001", "001"}, {"0", "001", "001"}]) == true
  end 
  
  test "FDA6" do 
    require IEx    
    assert Automata.runFDA(["1", "0", "1", "0", "1", "0", "1", "0", "1"], "lambda", ["001"], [{"1", "lambda", "lambda"}, {"0", "lambda", "0"}, {"1", "0", "lambda"}, {"0", "0", "00"}, {"0", "00", "00"}, {"1", "00", "001"}, {"1", "001", "001"}, {"0", "001", "001"}]) == false
  end
  
  # DFA Costas Busch, slide 51
  # Aceita cadeias com prefixo ab
  test "FDA7" do 
    require IEx    
    assert Automata.runFDA(["a", "b", "b"], "q0", ["q2"], [{"a", "q0", "q1"}, {"a", "q1", "q3"}, {"a", "q3", "q3"}, {"a", "q2", "q2"}, {"b", "q1", "q2"}, {"b", "q0", "q3"}, {"b", "q3", "q3"}, {"b", "q2", "q2"}]) == true
  end
  
  test "FDA8" do 
    require IEx    
    assert Automata.runFDA(["b", "a", "b"], "q0", ["q2"], [{"a", "q0", "q1"}, {"a", "q1", "q3"}, {"a", "q3", "q3"}, {"a", "q2", "q2"}, {"b", "q1", "q2"}, {"b", "q0", "q3"}, {"b", "q3", "q3"}, {"b", "q2", "q2"}]) == false
  end
  
  # NFA com Epsilon
  test "Epsilon1" do  
    require IEx    
    assert Automata.getPossibleFinalStates([{["a", "b", "a"], "q0"}], [{"a", "q0", "q1"}, {"b", "q1", "q2"}, {"a", "q2", "q2"}, {"", "q2", "q3"}, {"a", "q3", "q4"}], [], [{"a", "q0", "q1"}, {"b", "q1", "q2"}, {"a", "q2", "q2"}, {"", "q2", "q3"}, {"a", "q3", "q4"}], []) == ["q2", "q4"]
  end  
  
  # NFA com múltiplos caminhos
  test "Multiple1" do  
    require IEx    
    assert Automata.getPossibleFinalStates([{["a", "a"], "q0"}], [{"a", "q0", "q0"}, {"a", "q0", "q1"}, {"a", "q0", "q2"}, {"a", "q0", "q3"}, {"", "q2", "q4"}, {"a", "q4", "q5"}], [], [{"a", "q0", "q0"}, {"a", "q0", "q1"}, {"a", "q0", "q2"}, {"a", "q0", "q3"}, {"", "q2", "q4"}, {"a", "q4", "q5"}], []) == ["q0", "q1", "q2", "q3", "q5"]
  end  
  
  # NFA Costas Busch, slide 45
  # Aceita cadeias do tipo {ab}{ab}*
  test "FNDA1" do  
    require IEx    
    assert Automata.runFNDA(["a", "b"], "q0", ["q2"], [{"a", "q0", "q1"}, {"b", "q1", "q2"}, {"", "q2", "q3"}, {"", "q3", "q0"}]) == true
  end   
  
  test "FNDA2" do  
    require IEx    
    assert Automata.runFNDA(["a", "b", "a", "b"], "q0", ["q2"], [{"a", "q0", "q1"}, {"b", "q1", "q2"}, {"", "q2", "q3"}, {"", "q3", "q0"}]) == true
  end   
  
  test "FNDA3" do  
    require IEx    
    assert Automata.runFNDA(["a", "b", "a", "a"], "q0", ["q2"], [{"a", "q0", "q1"}, {"b", "q1", "q2"}, {"", "q2", "q3"}, {"", "q3", "q0"}]) == false
  end 
  
  test "FNDA4" do  
    require IEx    
    assert Automata.runFNDA(["a", "b", "c", "a"], "q0", ["q2"], [{"a", "q0", "q1"}, {"b", "q1", "q2"}, {"", "q2", "q3"}, {"", "q3", "q0"}]) == false
  end 

  # NFA Costas Busch, slide 47
  # Aceita cadeias do tipo {10}*

  test "FNDA5" do  
    require IEx    
    assert Automata.runFNDA(["1", "0", "1", "0"], "q0", ["q0"], [{"1", "q0", "q1"}, {"0", "q1", "q2"}, {"1", "q1", "q2"}, {"", "q0", "q2"}, {"0", "q1", "q0"}]) == true
  end   
  
  test "FNDA6" do  
    require IEx    
    assert Automata.runFNDA([], "q0", ["q0"], [{"1", "q0", "q1"}, {"0", "q1", "q2"}, {"1", "q1", "q2"}, {"", "q0", "q2"}, {"0", "q1", "q0"}]) == true
  end 
  
  test "FNDA7" do  
    require IEx    
    assert Automata.runFNDA(["1", "1", "0"], "q0", ["q0"], [{"1", "q0", "q1"}, {"0", "q1", "q2"}, {"1", "q1", "q2"}, {"", "q0", "q2"}, {"0", "q1", "q0"}]) == false
  end 
  
end

ExUnit.Server.modules_loaded()

ExUnit.run()
