# Very quick, unpolished script to page through events

events = []
$('.event-panel').each(-> events.push($(this)))

for event, i in events
  event.find('.number-container').text("#{i+1}/#{events.length}")

# Shuffle list order
for i in [0..events.length-1]
  randomI = i+1+Math.floor(Math.random()*(events.length-i-1))
  tmp = events[i]
  events[i] = events[randomI]
  events[randomI] = tmp

index = 0

events[index].removeClass('hidden')

$('.pager .next').click ->
  events[index].addClass('hidden')
  index++
  events[index].removeClass('hidden')

$('.pager .previous').click ->
  events[index].addClass('hidden')
  index--
  events[index].removeClass('hidden')
