Feature: Imports

  Scenario: Importing from standard library

    Given the System is
      """
      @import finitio/data

      String
      """
    Then it compiles fine

    Given "my" has been registered as stdlib
    Given the System is
      """
      @import my/commons

      Euros
      """
    Then it compiles fine
    Given I dress JSON's '12'
    Then the result should be a representation for Euros
    And  the result should be the integer 12
