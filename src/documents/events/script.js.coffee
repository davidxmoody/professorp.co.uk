# Very quick, unpolished script to page through events

# Create a list of jQuery objects representing each event panel
events = []
$('.event-panel').each(-> events.push($(this)))

# Add in a bit of text specifying the number of each panel (to make it move
# obvious to the user how many total events there are)
for event, i in events
  event.find('.number-container').text("#{i+1}/#{events.length}")

# Shuffle list order (so the same few events aren't always shown)
for i in [0..events.length-1]
  # Choose an index for a random element and swap it with the current element
  randomI = Math.floor(Math.random()*events.length)
  tmp = events[i]
  events[i] = events[randomI]
  events[randomI] = tmp

# Display the first one
index = 0
events[index].removeClass('hidden')

# Add two click handlers to cycle through the event panels
$('.pager .next').click ->
  events[index].addClass('hidden')
  index = (index+1)%events.length
  events[index].removeClass('hidden')

$('.pager .previous').click ->
  events[index].addClass('hidden')
  index = (index-1+events.length)%events.length
  events[index].removeClass('hidden')
