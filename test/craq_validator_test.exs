defmodule CraqValidatorTest do
  use ExUnit.Case
  # doctest CraqValidator

  describe "validate_craq/2" do
    setup do
      %{
        one_answer_list: [%{text: "This is a question?", options: [%{text: "yes"}, %{text: "no"}, %{text: "maybe"}]}],
        two_answer_list: [
          %{
            text: "Do you want an answer?",
            options: [
              %{text: "yes"},
              %{text: "no"}
            ]
          },
          %{text: "This is a question?", options: [%{text: "yes"}, %{text: "no"}]}
        ],
        two_answer_completed_if_list: [
          %{
            text: "Do you want an answer?",
            options: [
              %{text: "yes", complete_if_selected: true},
              %{text: "no"}
            ]
          },
          %{text: "This is a question?", options: [%{text: "yes"}, %{text: "no"}]}
        ]
      }
    end

    # Answers are completely missing
    test "invalid when empty map received", %{one_answer_list: answer_list} do
      # assert %{q0: "was not answered"} == CraqValidator.validate_craq(%{}, answer_list)
      assert [%{q0: "was not answered"}] == CraqValidator.validate_craq(%{}, answer_list)
    end

    test "invalid when nil received", %{one_answer_list: answer_list} do
      assert [%{q0: "was not answered"}] == CraqValidator.validate_craq(nil, answer_list)
    end

    test "invalid for each question when nil is received", %{two_answer_list: answer_list} do
      # assert %{q0: "was not answered", q1: "was not answered"} == CraqValidator.validate_craq(nil, answer_list)
      assert [%{q0: "was not answered"}, %{q1: "was not answered"}] == CraqValidator.validate_craq(nil, answer_list)
    end

    test "invalid for each question when empty map is received", %{two_answer_list: answer_list} do
      # assert %{q0: "was not answered", q1: "was not answered"} == CraqValidator.validate_craq(nil, answer_list)
      assert [%{q0: "was not answered"}, %{q1: "was not answered"}] == CraqValidator.validate_craq(%{}, answer_list)
    end

    # One answer list
    test "valid response when answer is present in options", %{one_answer_list: answer_list} do
      assert %{q0: 0}
      |> CraqValidator.validate_craq(answer_list)
      |> Enum.empty?()
    end

    test "valid when third (last) answer option is chosen", %{one_answer_list: answer_list} do
      assert %{q0: 2}
      |> CraqValidator.validate_craq(answer_list)
      |> Enum.empty?()
    end

    test "returns invalid response when answer is invalid", %{one_answer_list: answer_list} do
     assert [%{q0: "has an answer that is not on the list of valid answers"}]
     == CraqValidator.validate_craq(%{q0: 3}, answer_list)
    end

    # Two answer lists
    test "valid when all questions answered", %{two_answer_list: answer_list} do
      assert [] == CraqValidator.validate_craq(%{q0: 1, q1: 0}, answer_list)
    end

    test "invalid when only one question out of two answered", %{two_answer_list: answer_list} do
      assert [%{q1: "was not answered"}] == CraqValidator.validate_craq(%{q0: 1}, answer_list)
    end

    test "invalid when second question answered but not first question", %{two_answer_list: answer_list} do
      assert [%{q0: "was not answered"}] == CraqValidator.validate_craq(%{q1: 1}, answer_list)
    end

    # Two answer lists with completed_if_selected option (q0: 0)
    test "valid when no questions answered after completed_if_selected question", %{two_answer_completed_if_list: answer_list} do
      assert [] == CraqValidator.validate_craq(%{q0: 0}, answer_list)
    end

    test "valid if completed_if_selected not selected and both questions answered", %{two_answer_completed_if_list: answer_list} do
      assert [] == CraqValidator.validate_craq(%{q0: 1, q1: 0}, answer_list)
    end

    test "invalid when question answered after completed_if_selected question", %{two_answer_completed_if_list: answer_list} do
      assert [
        %{
          q1: "was answered even though a previous response indicated that the questions were complete"
        }
      ]
        == CraqValidator.validate_craq(%{q0: 0, q1: 0}, answer_list)
    end
  end
end
