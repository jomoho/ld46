
extends Control
tool


var session_time=0 setget _set_session_time
var time=0 setget _set_time

const PATH = 'res://addons/work-time/'

var reset_time = 0

func _set_time(value):
	time = value
	get_node('box/total/Time').set_text(display_time(time))

func _set_session_time(value):
	session_time = value
	get_node('box/session/Time').set_text(display_time(session_time,true))

func save():
	
	var file = File.new()
	var opened = file.open(PATH+'time.json', File.WRITE)
	var json = JSON.print({'time': time})
	print("Saving: %s " % json);
	if opened == OK:
		file.store_line(json)
	
	file.close()

func restore():
	var file = File.new()
	var opened = file.open(PATH+'time.json', File.READ)
	if opened == OK:
		var data = {}
		while !file.eof_reached():
			data = JSON.parse(file.get_line()).result
		if data['time'] != null:
			set('time', data['time'])
		else:
			set('time', 0)
	set('session_time', 0)
		
func reset():
	set('time', 0)


func _enter_tree():
	restore()
	set_process(true)

func _exit_tree():
	save()

func _process(delta):
	if time != null:
		var new_time = time+delta
		set('time',new_time)
	else:
		restore()
	var new_session_time = session_time+delta
	set('session_time', new_session_time)
	

	if get_node('box/total/Reset').is_pressed():
		reset_time += delta
	else:
		reset_time = 0
	if reset_time >= 3.0:
		reset()
		reset_time = 0
		get_node('box/total/Reset').set_pressed(false)

func display_time(T, short=false):
	if T == null:	T=0
	T = int(T)
	var seconds = T % 60
	var minutes = T/60 % 60
	var hours = T/(60*60) % 24
	var days = T/(60*60*24)
	if short:
		return str(hours)+"h, "+str(minutes)+"m, "+str(seconds)+"s"
	else:
		return str(days)+" days\n"+str(hours)+" hours\n"+str(minutes)+" minutes\n"+str(seconds)+" seconds"

func _on_save_pressed():
	save()
	pass # Replace with function body.
