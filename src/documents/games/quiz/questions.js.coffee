#TODO require underscore for shuffle/sample function

class Answer
  constructor: (@text, @isCorrect=false, @isSelected=false, @isDisabled=false) ->

class Question
  constructor: (@text, correctAnswer, incorrectAnswers...) ->
    @answers = (new Answer(answer) for answer in incorrectAnswers)
    @answers.push(new Answer(correctAnswer, true))
    @answers = _.shuffle(@answers)

#TODO use browserify
window.getQuestions = (numQuestions) -> _.sample([
  new Question(
    "Where would you be most likely to find Professor P's phone?"
    "In Sleepy's basket"
    "On the hall table"
    "In the living room"
  )
  new Question(
    "What is the best way to find Professor P's phone?"
    "Call out and ask it where it is"
    "Ask Sleepy to go and fetch it"
    "Wait for it to ring"
  )
  new Question(
    "Which of Professor P's inventions is polite and helpful?"
    "His phone"
    "His fridge"
    "His dishwasher"
  )
  new Question(
    "Professor P's fridge is"
    "Grumpy"
    "Helpful"
    "Funny"
  )
  new Question(
    "What is the best way to open Professor P's fridge?"
    "Ask it nicely"
    "Yank the handle hard"
    "Prise it open with a screwdriver"
  )
  new Question(
    "Which of Professor P's inventions is bad tempered?"
    "His fridge"
    "His toaster"
    "His washing machine"
  )
  new Question(
    "Professor P's toaster"
    "Tells jokes"
    "Explodes!"
    "Hates mornings"
  )
  new Question(
    "Professor P's toaster"
    "Sometimes burns toast"
    "Never burns toast"
    "Always burns toast"
  )
  new Question(
    "Which of Professor P's inventions tells jokes?"
    "His toaster"
    "His fridge"
    "His dishwasher"
  )
  new Question(
    "Which of Professor P's inventions doesn't know when to stop talking?"
    "His toaster"
    "His phone"
    "His washing machine"
  )
  new Question(
    "Professor P's front door"
    "Talks in a loud commanding voice"
    "Often bursts into fits of giggles"
    "Laughs loudly"
  )
  new Question(
    "Which of Professor P's inventions talks in a loud commanding voice?"
    "His front door"
    "His phone"
    "His watch"
  )
  new Question(
    "What's unusual about Professor P's cans of self-heating beans?"
    "They sometimes explode"
    "They always explode"
    "They don't heat up the beans"
  )
  new Question(
    "Which of Professor P's inventions is most likely to explode"
    "His can of self-heating beans"
    "His toaster"
    "His phone"
  )
  new Question(
    "What is unusual about Professor P dishwasher"
    "Nothing, it's just an ordinary dishwasher"
    "It also washes clothes"
    "It often breaks the dishes"
  )
  new Question(
    "Which of Professor P's inventions does not talk?"
    "His dishwasher"
    "His phone"
    "His watch"
  )
  new Question(
    "What colour is Professor P's watch?"
    "Purple"
    "Pink"
    "Blue"
  )
  new Question(
    "What is unusual about Professor P's watch?"
    "It reminds him of appointments"
    "It often gets the time wrong"
    "It keeps falling off his wrist"
  )
  new Question(
    "What is the problem with Professor P's automatic dog bathing machine?"
    "It pulled some hairs out of Sleepy"
    "It doesn't get Sleepy clean"
    "Nothing, it works fine"
  )
  new Question(
    "What is the problem with Professor P's electric flea comb?"
    "It gave Sleepy an electric shock"
    "It doesn't kill fleas"
    "Nothing, it works fine"
  )
  new Question(
    "What is the problem with Professor P's automatic pet feeder?"
    "Nothing, it works fine"
    "It gave Professor P's cats an electric shock"
    "It explodes"
  )
  new Question(
    "Which of Professor P's pet products works very well?"
    "The automatic pet feeder"
    "The automatic dog bathing machine"
    "The electric flea comb"
  )
  new Question(
    "What's special about Professor P's solar powered kettle?"
    "It can use sea water"
    "It tells jokes"
    "It explodes"
  )
  new Question(
    "What's special about Professor P's dinghy?"
    "It's solar powered and self-inflating"
    "Nothing, it's just an ordinary dinghy"
    "It explodes"
  )
  new Question(
    "The metal detector Peter and Tara built"
    "Blew up"
    "Worked fine"
    "Did not have enough capacitors"
  )
  new Question(
    "What is unusual about the lights in Professor P's basement?"
    "They won't switch on unless you say \"please\""
    "They switch on automatically"
    "They don't work"
  )
  new Question(
    "What is the problem with Professor P's solar powered cool box?"
    "There's no room for the food"
    "It freezes the food"
    "It explodes"
  )
  new Question(
    "What is unusual about the coloured balls in Professor P's basement?"
    "They don't stop bouncing"
    "They explode"
    "Nothing, they are just ordinary plastic balls"
  )
  new Question(
    "What is unusual about the Professor P's answer phone?"
    "It won't let you talk to Professor P if you're trying to sell something"
    "It doesn't record messages"
    "It explodes"
  )
  new Question(
    "What is unusual about the Professor P's answer phone?"
    "It sings badly"
    "Nothing, it works fine"
    "It explodes"
  )
], numQuestions)
