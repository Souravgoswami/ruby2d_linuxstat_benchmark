#!/usr/bin/env ruby
# Written by Sourav Goswami!
# GNU General Public License v3.0
%w(rubygems bundler).each(&method(:require))
Bundler.require(:default)

::STARS = 200
::GRASS_PARTICLES = 150
::FIRE_PARTICLES = 1500
::PUMPKIN_FIRE_PARTICLES = 2600

$width, $height = 640, 480
set(title: "Happy Halloweens Day", resizable: true, fps_cap: 60, icon: File.join(__dir__, 'assets', 'icon.png'), width: $width, height: $height)

# Backgrounds
Rectangle.new(width: $width, height: $height, color: %w(#000055 #000055 #0000aa #0000aa), z: -1000)
house = Image.new(File.join(__dir__, 'assets', 'background.png'), width: $width, height: $height, z: -500)

# Draw the pumpkin images
pumpkin, pumpkin_touched = Image.new(File.join(__dir__, 'assets', 'pumpkin.png'), width: 154, height: 159, color: '#770000').tap { |x| x.y = $height - x.height }, false
pumpkin2, pumpkin2_touched = Image.new(File.join(__dir__, 'assets', 'pumpkin2.png'), width: 154, height: 159, color: '#770000').tap { |x| x.x, x.y = $width - x.width, $height - x.height }, false

# Create the lamp post image!
lantern = Image.new(File.join(__dir__, 'assets', 'lantern.png'), z: -100, color: '#ffff00').tap { |x| x.x, x.y = $width - x.width - 100, $height - x.height - 60}
light = Array.new(25) { |i| Circle.new(radius: i, color: '#FFFFFF', opacity: (25.0 - i) / 200, x: lantern.x + lantern.width / 2, y: lantern.y + 20, sectors: 8) }

# window of the house
window1 = Rectangle.new(width: 35, height: 15, x: 230, y: 205, z: house.z - 1, color: %w(#ff0000 #ff0000 #005500 #002200))
window2 = Rectangle.new(width: 20, height: 35, x: 310, y: 185, z: house.z - 1, color: %w(#ff0000 #ffff00 #000000 #000000))
Rectangle.new width: 20, height: 15, x: 310, y: 70, z: house.z - 1, color: %w(#FFFF00 #FF0000 #FF00FF  #0000FF)

# Draw the halloween fire base!
circles, circles2 = [], []
circles_size = 15.times do |i|
	circles << Circle.new(radius: i * 2.5, z: -i, color: '#FFFF00', x: pumpkin.x + pumpkin.width / 2, y: pumpkin.y + pumpkin.height - i - 25, opacity: i / 40.0, sectors: 8)
	circles2 << Circle.new(radius: i * 2.5, z: -i, color:'#FFFF00', x: pumpkin2.x + pumpkin2.width / 2, y: pumpkin2.y + pumpkin2.height - i - 25, opacity: i / 40.0, sectors: 8)
end

# Particles on the black grass (bg image)
grasses = Array.new(GRASS_PARTICLES) { Square.new(x:rand(0..$width), y: rand($height - 50..$height), size: rand(1..2), z: -100, color: %w(#3ce3b4 #ffffff #ffff00).sample) }

# Draw the fires (drawn while moving the mouse), fire_base is its variable
fire_base = Array.new(15) { |i| Circle.new(radius: i * 1.5, color: '#FFFF00', z: 150, opacity: (i / 50.0), sectors: 12) }

# fire_particles stores all the fires that are drawn while you move the cursor
fire_particles = Array.new(FIRE_PARTICLES) { |i| Circle.new(radius: rand(1..12), x: 0, y: 0, z: -i + 200, opacity: 1, sectors: 32, color: '#FFFF00') }

# small_stars are drawn below the haunted house, stars are what you see in the sky!
small_stars = Array.new(STARS) { Square.new(size: 1, x: rand(0..$width), y: rand(0..$height - 100), color: '#FFFFFF', z: -505) }
stars = Array.new(20) { Circle.new(radius: 2, z: -1000, color: '#FFFF00', x: rand($width), y: rand($height), sectors: 12) }

# System monitor stuff
fps = Text.new('FPS: 0')
cpu_usage = Text.new('CPU: 0', y: fps.y + fps.height)
allocated = Text.new("Allocated CPU: #{LS::ProcessInfo.nproc}", y: cpu_usage.y + cpu_usage.height)
memory_usage = Text.new('Memory: 0', y: allocated.y + allocated.height)
pid = Text.new('PID: 0', y: memory_usage.y + memory_usage.height)
threads = Text.new('Threads: 0', y: pid.y + pid.height)
command = Text.new('Command: ...', y: threads.y + threads.height)
running_time = Text.new('Running: ...', y: command.y + command.height)
started = Text.new('Started: ...', y: running_time.y + running_time.height)

# system wise info
battery = LS::Battery.present? ? Text.new('Battery: ...').tap { |x| x.x = $width - x.width + 4 } : nil
global_cpu_usage = Text.new('Global CPU Usage: ...', y: battery.y + battery.height).tap { |x| x.x = $width - x.width + 12 }

pumpkin1_fire, pumpkin2_fire = [], []
PUMPKIN_FIRE_PARTICLES.times do |i|
	pumpkin1_fire << Circle.new(x: rand(pumpkin.x + 70..pumpkin.x + pumpkin.width- 70), y: pumpkin.y + pumpkin.height - 35, radius: rand(1..5), sectors: 12, color: '#FFFF00', z: -100)
	pumpkin2_fire << Circle.new(x: rand(pumpkin.x + 40..pumpkin.x + pumpkin.width- 40), y: pumpkin.y + pumpkin.height - 35, radius: rand(1..5), sectors: 12, color: '#FFFF00', z: -100)
end
thr = Thread.new { }

i = 0
update do
	i += 1

	# LinuxStat stuff
	fps.text = "FPS: #{sprintf("%.2f".freeze, get(:fps))}"

	unless thr.alive?
		thr = Thread.new {
			cpu_usage.text = "CPU: #{sprintf("%.2f".freeze, LS::ProcessInfo.cpu_usage(sleep: 0.25))} %% (#{LS::ProcessInfo.thread_usage(sleep: 0.25)} %% on CPU #{LS::ProcessInfo.last_executed_cpu + 1})"
			global_cpu_usage.text = "Total CPU Usage: #{sprintf "%.2f".freeze, LS::CPU.total_usage(0.25) }%% (#{LS::CPU.count_online} / #{LS::Sysconf.processor_configured})"

			global_cpu_usage.x = $width - global_cpu_usage.width - 4
		}
	end

	memory_usage.text = "Memory: #{LS::PrettifyBytes.convert_short_binary LS::ProcessInfo.memory * 1024}"
	io = LS::ProcessInfo.total_io
	pid.text = "IO: Read #{LS::PrettifyBytes.convert_short_binary io[:read_bytes]} | Write #{LS::PrettifyBytes.convert_short_binary io[:write_bytes]}"

	threads.text = "Threads: #{LS::ProcessInfo.threads}"
	command.text = "Cmdline: #{LS::ProcessInfo.cmdline}"

	running_time.text = "Running: #{sprintf("%.2f", LS::ProcessInfo.running_time)} sec (state: #{LS::ProcessInfo.state})"
	started.text = "Started: #{LS::ProcessInfo.start_time.strftime("%A, %d %b %Y, %H:%M:%S")}"

	if battery
		battery.text = "Battery: #{sprintf "%.2f", LS::Battery.charge}%% (#{LS::Battery.status})"
		battery.x = $width - battery.width - 4
	end

	# Animate the fire (circles) drawn behind pumpkins
	PUMPKIN_FIRE_PARTICLES.times do |index|
		f, f2 = pumpkin1_fire[index], pumpkin2_fire[index]

		f.x, f.y, f.opacity, f.radius = f.x + Math.sin(i / rand(1.0..8.0)) * 8.0, f.y - rand(5.0..8.0), f.opacity - 0.05, f.radius - 0.5
		f.r -= 0.05 if f.r > 0 && rand < 0.75
		f.b += 0.05 if f.b < 1 && rand < 0.5
		f.x, f.y, f.color, f.radius = rand(pumpkin.x + 40..pumpkin.x + pumpkin.width - 40), pumpkin.y + pumpkin.height - 35, [1, 0, 0, 1], rand(5..20) if (f.radius <= 0).|(f2.opacity <= 0)

		f2.x, f2.y, f2.opacity, f2.radius = f2.x + Math.sin(i / rand(1.0..8.0)) * 8.0, f2.y - rand(5.0..8.0), f2.opacity - 0.05, f2.radius - 0.5
		f2.r -= 0.05 if f2.r > 0 && rand < 0.75
		f2.b += 0.05 if f2.b < 1 && rand < 0.5
		f2.x, f2.y, f2.color, f2.radius = rand(pumpkin2.x + 40..pumpkin2.x + pumpkin2.width - 40), pumpkin2.y + pumpkin2.height - 35, [1, 0, 0, 1], rand(5..20) if (f2.radius <= 0).|(f2.opacity <= 0)
	end

	# flash the light of the house randomly, give the haunted house look and feel
	window1.color = ['#ffff00', %w(#ff0000 #ff0000 #005500 #002200)].sample
	window2.color = [true, [false] * 3].flatten.sample ? %w(#ff0000 #ffff00 #000000 #000000 ) : 'black'

	# flash the lamp
	light.each { |l| l.r, l.b = [0, 1].sample, [0, 1].sample }

	# Move the fire_base with mouse
	fire_base.each { |f| f.x, f.y = get(:mouse_x) + Math.sin(i), get(:mouse_y) + Math.cos(i) }

	fire_particles.each do |pr|
		pr.x, pr.y, pr.radius, pr.opacity = pr.x, pr.y - 7, pr.radius - rand(0.1..1), pr.opacity - 0.02
		pr.g -= 0.1 if pr.g > 0
		pr.r -= 0.025 if pr.r > 0
		pr.b += 0.1 if pr.g < 0.25
		pr.x, pr.y, pr.radius, pr.color = rand(get(:mouse_x) - 12..get(:mouse_x) + 12), rand(get(:mouse_y) - 8..get(:mouse_y) + 8), rand(2..10), [1, 1, 0, 0.5] if pr.radius.<=(0).|(pr.opacity.<=(0))
	end

	# flash the stars
	stars.each { |val| val.opacity = [0, 1].sample }

	small_stars.each_with_index do |pixel, index|
		pixel.y, pixel.opacity = pixel.y - index / (STARS / 10.0), [1, 0].sample
		pixel.x, pixel.y = rand(0..$width), $height if pixel.y <= 0
	end

	grasses.sample.opacity = [1 ,0].sample if Time.new.strftime('%N')[0].to_i % 2 == 0
	pumpkin_touched ? (pumpkin.r += 0.025 if pumpkin.r < 0.8) : (pumpkin.r -= 0.05 if pumpkin.r > 0.5)
	pumpkin2_touched ? (pumpkin2.r += 0.025 if pumpkin2.r < 0.8) : (pumpkin2.r -= 0.05 if pumpkin2.r > 0.5)

	circles_size.times { |val| circles[val].x, circles2[val].x= circles[val].x + Math.sin(val + i) * 5.0, circles2[val].x + Math.sin(val + i) * 5.0 }
end

on(:key_down) { |k| exit if %w(escape p q).include?(k.key) }
on(:mouse_move) { |e| pumpkin_touched, pumpkin2_touched = pumpkin.contains?(e.x, e.y), pumpkin2.contains?(e.x, e.y) }

show
