defmodule CraqValidator do
  @moduledoc """
  Documentation for `CraqValidator`.
  """

  @doc """

  ## Examples

      iex> CraqValidator.

  """

  @hash_index_map %{q0: 0, q1: 1, q2: 2, q3: 3, q4: 4}
  @key_map %{0 => :q0, 1 => :q1, 2 => :q2, 3 => :q3, 4 => :q4}
  # TODO:
  # module doc
  # doc
  # rest of tests
  # change master to main
  # README

  # [%{
  #     text: "Why did you not select 42 as the answer to the previous question?",
  #     options: [
  #       %{ text: "I'd far rather be happy than right any day", complete_if_selected: true },
  #       %{ text: "I don't get that reference" }
  #     ]
  #   }
  # ]
  # %{q0: 2}

  # POSSIBLE SOLUTION #1
  # Enumerate over answers, get index
  # use index to get qx atom key
  # use atom key to get answer from user
  # if answer from user is not present in options, not a valid answer message
  # if answer from user is present AND complete if selected, add answers_complete atom to acc to signal to subsequent questions to send "already answered" message
  # further validation with options_list_check function

  def craq_validator(answer_map_from_user, question_answer_list) do
    # Keyword list
    question_answer_list_with_index = Enum.with_index(question_answer_list)
    Enum.reduce(question_answer_list_with_index, [], fn {%{options: answer_options_list}, index}, acc ->
      atom_key = Map.get(@key_map, index)
      # answer_from_user = get_user_answer(answer_map_from_user, atom_key, acc)

      question_response_map =
      with answer_from_user when is_integer(answer_from_user) <- get_user_answer(answer_map_from_user, atom_key, acc) do
        case Enum.at(answer_options_list, answer_from_user) do
          nil -> %{atom_key => "has an answer that is not on the list of valid answers"}
          %{complete_if_selected: true} -> %{answers_complete: true}
          _ -> %{answers_complete: false}
        end
      else
        user_answer_map ->
          user_answer_map
      end

      [question_response_map | acc]
      # Map.merge(acc, question_response_map)
    end)
    |> IO.inspect(label: "what is right before list reverse?")
    |> Enum.reverse()
    |> IO.inspect(label: "what is right after list reverse?")
    # Filter out answers_complete and ok properties
    # |> Enum.reject(fn {key, _val} -> key in [:ok, :answers_complete] end)
    |> Enum.reject(fn map_item -> Map.has_key?(map_item, :answers_complete) end)
    # |> Enum.reject(fn map_item ->
    #   for {key, val} <- map_item do
    #     IO.inspect(key, label: "key")
    #     IO.inspect(val, label: "value")
    #     key in [:ok, :answers_complete]
    #   end
    # end)
    # If map is empty, return %{craq_valid: true} or {:ok, %{craq_valid: true}}
    # If map is not empty, return {:error, invalid_reasons_map}
  end

  defp get_user_answer(nil, atom_key, _), do: %{atom_key => "was not answered"}
  defp get_user_answer(map, atom_key, _) when map_size(map) == 0, do:  %{atom_key => "was not answered"}

  # If there is the answers_complete property in the map,
  # and you can't find a user answer for this question,
  # return %{ok: true}
  # if you CAN find a user answer for this question,
  # return "was answered" message
  defp get_user_answer(user_answer_map, atom_key, acc_list) do
    if %{answers_complete: true} in acc_list do
      case Map.get(user_answer_map, atom_key, nil) do
        nil -> %{ok: true}
        _ -> %{
          atom_key =>
            "was answered even though a previous response indicated that the questions were complete"
        }
      end
    else
      case Map.get(user_answer_map, atom_key, nil) do
        nil -> %{atom_key => "was not answered"}
        user_answer -> user_answer
      end
    end
  end

  # defp get_user_answer(user_answer_map, atom_key, %{answers_complete: true}) do
  #   case Map.get(user_answer_map, atom_key, nil) do
  #     nil -> %{ok: true}
  #     _ -> %{
  #       atom_key =>
  #         "was answered even though a previous response indicated that the questions were complete"
  #     }
  #   end
  # end

  # # If there isn't the answers_complete property in the map,
  # # and you can't find a user answer for this question,
  # # return "was not answered" message
  # # if you CAN find a user answer for this question,
  # # return %{:ok, true}
  # defp get_user_answer(user_answer_map, atom_key, _) do
  #   case Map.get(user_answer_map, atom_key, nil) do
  #     nil -> %{atom_key => "was not answered"}
  #     user_answer -> user_answer
  #   end
  # end


  # POSSIBLE SOLUTION #2
  # @spec craq_validator(map(), list()) :: map()
  # def craq_validator(answers_map, question_answer_list) do
  #   # check map size
  #   map_size = map_size(answers_map)

  #   # put map from user into keyword list in ascending order
  #   answers_list =
  #   Enum.reduce(0..(map_size - 1), [], fn num, acc ->
  #     key = Map.get(@key_map, num)
  #     answer_map = Map.get(answers_map, key)
  #     Enum.to_list(answer_map) ++ acc
  #   end)

  #   Enum.reduce(answers_list, %{}, fn {question_hash_atom, answer_from_user}, acc ->
  #     # convert answer key atom into index integer
  #     question_answer_index = Map.get(@hash_index_map, question_hash_atom)
  #     # get correct map of question and answer options from list using integer as index
  #     %{options: answer_options_list} = Enum.at(question_answer_list, question_answer_index)

  #     question_response_map =
  #       case Enum.at(answer_options_list, answer_from_user) do
  #         nil -> %{question_hash_atom => "has an answer that is not on the list of valid answers"}
  #         %{complete_if_selected: true} -> %{answers_complete: true}
  #         _ -> options_list_check(answer_options_list, answers_list, acc)
  #       end

  #     Map.put(acc, question_hash_atom, question_response_map)

  #     # If complete_if_selected option is present, and if that answer is selected,then the validation is finished (put complete_if_selected: true)
  #     # DONE If complete_if_selected option is present, and if that answer has already been answered, "already answered" message
  #     # If answer is valid, proceed (return something throwaway like %{valid_answer: true})
  #     # (Don't have to worry about this if iterating over questions) If complete_if selected option is present, and if that answer is NOT the selected one that was chosen,
  #     # then there MUST be another answer in the map one above current hash (eg q1 must have q2 in map)
  #   end)
  # end

  # def options_list_check(_options_list, {question_hash_atom, _answer_from_user}, %{
  #       answers_complete: true
  #     }) do
  #   %{
  #     question_hash_atom =>
  #       "was answered even though a previous response indicated that the questions were complete"
  #   }
  # end

  # def options_list_check(options_list, {question_hash_atom, answer_from_user}, _acc) do
  #   %{complete_if_selected: true} = Enum.at(options_list, answer_from_user)
  # end
end
