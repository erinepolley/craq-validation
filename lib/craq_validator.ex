defmodule CraqValidator do
  @moduledoc """
  Used for CRAQ validation when changes are requested by a user.
  """

  @key_map %{0 => :q0, 1 => :q1, 2 => :q2, 3 => :q3, 4 => :q4}

  @doc """
  This function validates two things: the presence of an answer,
  and the answer itself.

  When a valid answer is chosen that has the complete_if_selected property,
  a %{answers_complete: true} map is added to the accumulator to indicate that
  subsequent questions should not have answers.

  If there is no %{answers_complete: true} map, and an answer is missing,
  it indicates that we need to send an error message to the user.

  If a valid answer is selected, but does not have the complete_if_selected property,
  a %{answers_complete: false} map is added to the accumulator as a throwaway value.
  All maps with the key of :answers_complete are filtered from the errors accumulator.

  """
  @spec validate_craq(map(), list(map())) :: list(map())
  def validate_craq(user_answers, question_list) do
    question_list
    |> Enum.with_index()
    |> Enum.reduce([], fn {%{options: answer_options}, index}, acc ->
      atom_key = Map.get(@key_map, index)

      question_response_map =
        case validate_answer_presence(user_answers, atom_key, acc) do
          %{user_answer: user_answer} -> validate_answer_value(answer_options, user_answer, atom_key)
          response_map -> response_map
        end

      [question_response_map | acc]
    end)
    |> Enum.reverse()
    |> Enum.reject(fn map_item -> Map.has_key?(map_item, :answers_complete) end)
  end

  def missing_answer, do: "was not answered"
  def invalid_answer, do: "has an answer that is not on the list of valid answers"

  def terminal_answer_reached,
    do: "was answered even though a previous response indicated that the questions were complete"

  @spec validate_answer_presence(nil | map(), atom(), list(map())) :: map()
  defp validate_answer_presence(nil, atom_key, _), do: %{atom_key => missing_answer()}

  defp validate_answer_presence(user_answers, atom_key, _) when map_size(user_answers) == 0,
    do: %{atom_key => missing_answer()}

  defp validate_answer_presence(user_answers, atom_key, acc) do
    if Enum.member?(acc, %{answers_complete: true}) do
      case Map.get(user_answers, atom_key, nil) do
        nil -> %{answers_complete: true}
        _ -> %{atom_key => terminal_answer_reached()}
      end
    else
      case Map.get(user_answers, atom_key, nil) do
        nil -> %{atom_key => missing_answer()}
        user_answer -> %{user_answer: user_answer}
      end
    end
  end

  @spec validate_answer_value(list(map()), integer(), atom()) :: map()
  defp validate_answer_value(answer_options, user_answer, atom_key) do
    case Enum.at(answer_options, user_answer) do
      nil -> %{atom_key => invalid_answer()}
      %{complete_if_selected: true} = _valid_answer -> %{answers_complete: true}
      _valid_answer -> %{answers_complete: false}
    end
  end
end
