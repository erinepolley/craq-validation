defmodule CraqValidatorTest do
  use ExUnit.Case
  # doctest CraqValidator

  describe "craq_validator/2" do
    setup do
      %{
        one_answer_list: [%{text: "This is a question?", options: [%{text: "yes"}, %{text: "no"}, %{text: "maybe"}]}],
        two_answer_list: [
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

    test "correct response returned when empty map received", %{one_answer_list: answer_list} do
      # assert %{q0: "was not answered"} == CraqValidator.craq_validator(%{}, answer_list)
      assert [%{q0: "was not answered"}] == CraqValidator.craq_validator(%{}, answer_list)
    end

    test "correct response returned when nil received", %{one_answer_list: answer_list} do
      assert [%{q0: "was not answered"}] == CraqValidator.craq_validator(nil, answer_list)
    end

    test "returns correct responses for each question when nil is received", %{two_answer_list: answer_list} do
      # assert %{q0: "was not answered", q1: "was not answered"} == CraqValidator.craq_validator(nil, answer_list)
      assert [%{q0: "was not answered"}, %{q1: "was not answered"}] == CraqValidator.craq_validator(nil, answer_list)
    end

    test "returns correct responses for each question when empty map is received", %{two_answer_list: answer_list} do
      # assert %{q0: "was not answered", q1: "was not answered"} == CraqValidator.craq_validator(nil, answer_list)
      assert [%{q0: "was not answered"}, %{q1: "was not answered"}] == CraqValidator.craq_validator(%{}, answer_list)
    end

    test "returns empty list when answer is valid", %{one_answer_list: answer_list} do
      assert %{q0: 0}
      |> CraqValidator.craq_validator(answer_list)
      |> Enum.empty?()
    end

    test "returns empty list when last answer option is chosen", %{one_answer_list: answer_list} do
      assert %{q0: 2}
      |> CraqValidator.craq_validator(answer_list)
      |> Enum.empty?()
    end

    test "returns invalid answer response when chosen answer option is not valid", %{one_answer_list: answer_list} do
     assert [%{q0: "has an answer that is not on the list of valid answers"}]
     == CraqValidator.craq_validator(%{q0: 3}, answer_list)
    end
  end
end
