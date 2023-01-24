defmodule CraqValidatorTest do
  use ExUnit.Case
  # doctest CraqValidator

  describe "craq_validator/2" do
    setup do
      %{
        one_answer_list: [%{text: "This is a question?", options: [%{text: "yes"}, %{text: "no"}]}],
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

    test "correct response returned when empty map received from front end", %{one_answer_list: answer_list} do
      assert %{q0: "was not answered"} == CraqValidator.craq_validator(%{}, answer_list)
    end

    test "correct response returned when nil received from front end", %{one_answer_list: answer_list} do
      assert %{q0: "was not answered"} == CraqValidator.craq_validator(nil, answer_list)
    end

    test "returns correct responses for each question in question list", %{two_answer_list: answer_list} do
      assert %{q0: "was not answered", q1: "was not answered"} == CraqValidator.craq_validator(nil, answer_list)
    end
  end
end
