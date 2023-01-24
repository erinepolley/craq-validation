defmodule CraqValidator do
  @moduledoc """
  Used for CRAQ validation when changes are requested by a user.
  """

  @doc """

  ## Examples

      iex> CraqValidator.

  """
  @key_map %{0 => :q0, 1 => :q1, 2 => :q2, 3 => :q3, 4 => :q4}
  # TODO:
  # module doc
  # doc
  # doc test?
  # DONE rest of tests--more than halfway finished!!
  # Refactor
  # change master to main
  # README

  # POSSIBLE SOLUTION #1
  # Enumerate over answers, get index
  # use index to get qx atom key
  # use atom key to get answer from user
  # if answer from user is not present in options, not a valid answer message
  # if answer from user is present AND complete if selected, add answers_complete atom to acc to signal to subsequent questions to send "already answered" message
  # further validation with options_list_check function

  @spec validate_craq(map(), list()) :: list()
  def validate_craq(answer_map_from_user, question_answer_list) do
    # Keyword
    question_answer_list
    |> Enum.with_index()
    |> Enum.reduce([], fn {%{options: answer_options_list}, index}, acc ->
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
    |> Enum.reverse()
    |> Enum.reject(fn map_item -> Map.has_key?(map_item, :answers_complete) end)
    # If map is empty, return %{craq_valid: true} or {:ok, []}
    # If map is not empty, return {:error, invalid_reasons_list}
  end

  defp get_user_answer(nil, atom_key, _), do: %{atom_key => "was not answered"}
  defp get_user_answer(map, atom_key, _) when map_size(map) == 0, do:  %{atom_key => "was not answered"}

  # If there is the answers_complete property in the map,
  # and you can't find a user answer for this question,
  # return %{ok: true}
  # if you CAN find a user answer for this question,
  # return "was answered" message
  defp get_user_answer(user_answer_map, atom_key, acc) do
    if Enum.member?(acc, %{answers_complete: true}) do
      case Map.get(user_answer_map, atom_key, nil) do
        nil -> %{answers_complete: true}
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
end
