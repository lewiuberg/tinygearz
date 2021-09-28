# Module of useful tools
from time import sleep


def sections(section_item):
    while True:
        try:
            if section_item == 0:
                print(
                    """
*******************************************************************************
********************************* Tiny Gearz **********************************
*******************************************************************************
"""
                )
                break
            elif section_item == 1:
                print(
                    """
*******************************************************************************
***************************** Database definition *****************************
*******************************************************************************
"""
                )
                break
            elif section_item == 2:
                print(
                    """
*******************************************************************************
*********************************** Queries ***********************************
*******************************************************************************
"""
                )
                break
            elif section_item == 21:
                print(
                    """
*******************************************************************************
******************************** Table chooser ********************************
*******************************************************************************
"""
                )
                break
            elif section_item == 7:
                print("\n" + "*" * 79, "\n")
                break
            elif section_item == 8:
                print("\n" + "-" * 79, "\n")
                break
            elif section_item == 9:
                # farewell message
                sections(7)
                print(
                    "\nThank you for using the TinyGearz user interface!"
                    " \n\nHave a nice day!\n"
                )
                sections(7)
                sleep(1)
                # Quits the program.
                quit()
            else:
                raise IndexError
        except IndexError:
            # Prints a error message that input is out of range.
            print("\nERROR in sections function! Out of range(0-9)!")
            break


def question_handler(questions, question_prompt):
    """Prompts multiple value question

    Args:
        questions: Dictionary containing questions
        question_prompt: Dictionary containing possible answers

    Returns: answer selected

    """
    keys = list(questions.keys())
    values = list(questions.values())
    for item in range(len(questions.keys())):
        question_prompt += "\n\n[" + str(keys[item]) + "] " + values[item]
    question_prompt += "\n\nAnswer: "

    # Asks for a input selection from selection.
    while True:
        try:
            answer = int(input(question_prompt))
            if answer in keys:
                answer = str(values[answer - 1])
                sections(2)
                break
            else:
                # Give ValueError if input is out of scope.
                raise ValueError
        except ValueError:
            print("\nInvalid input! Please try again!")
            sections(2)
    return answer
