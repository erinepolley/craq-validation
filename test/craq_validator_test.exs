defmodule CraqValidatorTest do
  use ExUnit.Case

  describe "validate_craq/2" do
    setup do
      question_one = %{
        text: "Do you like riddles?",
        options: [%{text: "yes"}, %{text: "no"}, %{text: "maybe"}]
      }

      completed_if_selected_question = %{
        text: "Do you like riddles?",
        options: [
          %{text: "no", complete_if_selected: true},
          %{text: "yes"}
        ]
      }

      question_two = %{
        text: "What have I got in my pocket?",
        options: [%{text: "a ring"}, %{text: "that's not a riddle"}]
      }

      %{
        one_question_list: [question_one],
        two_question_list: [question_one, question_two],
        two_question_completed_if_list: [completed_if_selected_question, question_two]
      }
    end

    # Answers are completely missing
    test "invalid when empty map received", %{one_question_list: answer_list} do
      assert [%{q0: CraqValidator.missing_answer()}] ==
               CraqValidator.validate_craq(%{}, answer_list)
    end

    test "invalid when nil received", %{one_question_list: answer_list} do
      assert [%{q0: CraqValidator.missing_answer()}] ==
               CraqValidator.validate_craq(nil, answer_list)
    end

    test "invalid for each question when nil is received", %{two_question_list: answer_list} do
      assert [%{q0: CraqValidator.missing_answer()}, %{q1: CraqValidator.missing_answer()}] ==
               CraqValidator.validate_craq(nil, answer_list)
    end

    test "invalid for each question when empty map is received", %{two_question_list: answer_list} do
      assert [%{q0: CraqValidator.missing_answer()}, %{q1: CraqValidator.missing_answer()}] ==
               CraqValidator.validate_craq(%{}, answer_list)
    end

    # One question list
    test "valid response when answer is present in options", %{one_question_list: answer_list} do
      assert %{q0: 0}
             |> CraqValidator.validate_craq(answer_list)
             |> Enum.empty?()
    end

    test "valid when third (last) answer option is chosen", %{one_question_list: answer_list} do
      assert %{q0: 2}
             |> CraqValidator.validate_craq(answer_list)
             |> Enum.empty?()
    end

    test "returns invalid response when answer is invalid", %{one_question_list: answer_list} do
      assert [%{q0: CraqValidator.invalid_answer()}] ==
               CraqValidator.validate_craq(%{q0: 3}, answer_list)
    end

    # Two question lists
    test "valid when all questions answered", %{two_question_list: answer_list} do
      assert %{q0: 1, q1: 0}
             |> CraqValidator.validate_craq(answer_list)
             |> Enum.empty?()
    end

    test "invalid when only one question out of two answered", %{two_question_list: answer_list} do
      assert [%{q1: CraqValidator.missing_answer()}] ==
               CraqValidator.validate_craq(%{q0: 1}, answer_list)
    end

    test "invalid when second question answered but not first question", %{
      two_question_list: answer_list
    } do
      assert [%{q0: CraqValidator.missing_answer()}] ==
               CraqValidator.validate_craq(%{q1: 1}, answer_list)
    end

    # Two question lists with completed_if_selected option (q0: 0)
    test "valid when no questions answered after completed_if_selected question", %{
      two_question_completed_if_list: answer_list
    } do
      assert %{q0: 0}
             |> CraqValidator.validate_craq(answer_list)
             |> Enum.empty?()
    end

    test "valid if completed_if_selected not selected and both questions answered", %{
      two_question_completed_if_list: answer_list
    } do
      assert %{q0: 1, q1: 0}
             |> CraqValidator.validate_craq(answer_list)
             |> Enum.empty?()
    end

    test "invalid when question answered after completed_if_selected question", %{
      two_question_completed_if_list: answer_list
    } do
      assert [
               %{
                 q1: CraqValidator.terminal_answer_reached()
               }
             ] ==
               CraqValidator.validate_craq(%{q0: 0, q1: 0}, answer_list)
    end
  end
end
