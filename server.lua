function array(m)
	local d = {}
	for o = 1, m do
		d[m] = 0
	end
	return d
end

imgid = array(32)
health = array(32)
ctimer = array(32)

addhook('join', 'join_hook')
function join_hook(id)
	health[id] = 100
	ctimer[id] = 0
	imgid[id] = image('gfx/screen.png', 320, 240, 2, id)
	imagealpha(imgid[id], 0)
end

addhook('hit', 'hit_hook')
function hit_hook(id, source, weapon, hpdmg, apdmg, rawdmg)
	if player(id, 'bot') then return end
	local a = player(id, 'armor')
	if a > 0 and a <= 200 then
		health[id] = health[id] - hpdmg
		parse('setarmor '.. id ..' '.. a - apdmg)
	elseif a == 0 or a > 200 then
		health[id] = health[id] - hpdmg
	end
	if health[id] <= 0 then
		health[id] = 100
		imagealpha(imgid[id], 0)
		ctimer[id] = 0
		parse('customkill '.. source ..' '.. itemtype(weapon, 'name') ..' '.. id) 
	end
	local k = 100 - health[id]
	k = k / 100
	imagealpha(imgid[id], k)
	ctimer[id] = 2
	return 1
end

addhook('ms100', 'ms100_hook')
function ms100_hook()
	for n, w in pairs(player(0, 'tableliving')) do
		if player(w, 'bot') then return end
		if ctimer[w] == 0 then
			if health[w] < 100 then
				health[w] = health[w] + 2
			else
				health[w] = 100
			end
		end
		local k = 100 - health[w]
		local k = k / 100
		imagealpha(imgid[w], k)
		parse('sethealth '.. w ..' '.. health[w])
	end
end

addhook('second', 'second_hook')
function second_hook()
	for n, w in pairs(player(0, 'tableliving')) do
		if player(w, 'bot') then return end
		if ctimer[w] > 0 then
			ctimer[w] = ctimer[w] - 1
		end
	end
end

addhook('leave', 'leave_hook')
function leave_hook(id)
	ctimer[id] = 0
	health[id] = 0
	imgid[id] = 0
end

addhook('startround', 'startround_hook')
function startround_hook()
	for n, w in pairs(player(0, 'table')) do
		if player(w, 'bot') then return end
		imgid[w] = image('gfx/screen.png', 320, 240, 2, w)
		health[w] = 100
		ctimer[w] = 0
	end
end