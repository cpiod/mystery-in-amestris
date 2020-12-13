pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- noname secret santa
-- cpiod

function _init()
-- o:
-- 0=up, 1=down, 2=left, 3=right
 p={x=23*8,y=7*8,o=1,f=false}
 p.ox=p.x
 p.oy=p.y
 
-- mode:
-- 1: move
-- 2: dialog
 mode=1
 transition=10
 
 npc={
 -- flags
 {nbspr=54,x=17,y=3},
 {nbspr=54,x=22,y=8},
 {nbspr=54,x=24,y=8},
 
 -- windows
 {nbspr=64,x=6,y=0},
 {nbspr=66,x=7,y=0},
 {nbspr=65,x=25,y=8},
 {nbspr=66,x=26,y=8},

 -- sheets on wall
 {nbspr=240,x=31,y=2},
 
 -- boxes
 {nbspr=70,x=29,y=7},
 {nbspr=70,x=30,y=6},
 {nbspr=55,x=32,y=6,w=true},
 {nbspr=71,x=32,y=7},

 -- transmutation
 {id=1003,nbspr=61,x=21,y=5},
 {id=1003,nbspr=62,x=22,y=5},
 {id=1003,nbspr=77,x=21,y=6},
 {id=1003,nbspr=78,x=22,y=6},

 -- books
 {nbspr=242,id=1001,x=24,y=3},
 {nbspr=241,id=1000,x=10,y=3},
 {nbspr=243,id=1002,x=29,y=7},
 {id=241,x=30,y=6},
  
 -- npc
 {id=1,x=14,y=2},
 {id=2,x=8,y=6,f=true},
 {id=3,x=5,y=6},
 
 -- tree
 {nbspr=56,x=3,y=4,w=true},
 {nbspr=72,x=3,y=5}}
 
 tele={{x1=7,y1=8,x2=23,y2=2,o=1},
 {x1=23,y1=2,x2=7,y2=8,o=0}}
	palt(0,false)
	palt(14,true)
	
	sort(npc)
end

function _update60()
 if mode==1 then
  update_move()
 elseif mode==2 then
  update_diag()
 end
end

function update_diag()
 if(btnp(⬆️) and slct>1) slct-=1
 if(btnp(⬇️) and slct<#a) slct+=1
 if btnp(🅾️) then
  nb=path[slct]
  if(nb==0 or nb==nil) mode=1 else change_dial()
 end
end

function update_move()
 local moving=p.x!=p.ox or p.y!=p.oy
 if(p.x<p.ox) p.x+=1
 if(p.x>p.ox) p.x-=1
 if(p.y<p.oy) p.y+=1
 if(p.y>p.oy) p.y-=1 
 if moving!=(p.x!=p.ox or p.y!=p.oy) then
  -- hero stopped. check teleporters
  for tp in all(tele) do
   if p.x/8==tp.x1 and p.y/8==tp.y1 then
    p.x=tp.x2*8
    p.y=tp.y2*8
    p.ox=p.x
    if(tp.o==0) p.oy=p.y-8 else p.oy=p.y+8
    break
   end
  end
 end
 
 if p.x==p.ox and p.y==p.oy then
  -- moving
	 local x,y=p.x,p.y
	 if(btn(⬆️)) p.o=0 y-=8
	 if(btn(⬇️)) p.o=1 y+=8
	 if(btn(➡️)) p.o=3 x+=8 p.f=false
	 if(btn(⬅️)) p.o=2 x-=8 p.f=true
	 if(x!=p.x)y=p.y
	 -- check collision
	 local mov=true
	 for n in all(npc) do
	 -- npc in path: stop moving, start chatting
	  if n.w!=true and n.x==x/8 and n.y==y/8 then
	   mov=false
	   if(n.id!=nil) start_dial(n.id)
	  end
	 end	 
	 if(not mov or not fget(mget(x/8,y/8),0)) x,y=p.x,p.y
	 p.ox,p.oy=x,y
 end
end

function sort(a)
 for i=1,#a do
  local j=i
  while j>1 and a[j-1].y>a[j].y do
   a[j],a[j-1]=a[j-1],a[j]
   j=j-1
  end
 end
end
-->8
-- dialog system
slct=1

faces={80,83,86,128}
names={"rOY mUSTANG","aMELIA sMITH","oWEN lOCKE","aNNA bERKELEY"}
local s="a book"
names[1000]=s
names[1001]=s
names[1002]=s
names[1003]="a transmutation circle"
-- nb: text id
-- d=text, list of lines
-- a=answers, list of lines
-- s=current selected answers
function cnt(t)
 local i=0
 for n=1,#t do
  if(sub(t,n,n)=="\n") i+=1
 end
 return i
end

function prt_dial()
 local i=cnt(d)
 for t in all(a) do
  i+=cnt(t)
 end
 if(#a>0) i+=1
 local maxy=8+6*(i+#a)
 local deltay=98-maxy
 local namex=5
 -- name
 if(faces[chat]!=nil) namex+=25 spr(faces[chat],camx+5,camy+deltay,3,3)
 for i=-1,1 do
  for j=-1,1 do
   print(names[chat],camx+namex+i,camy+deltay+18+j,0)
  end
 end
 print(names[chat],camx+namex,camy+deltay+18,6)
 
 -- bg
 rectfill(3+camx,24+camy+deltay,125+camx,maxy+camy+24+deltay,1)
 rect(3+camx,24+camy+deltay,125+camx,maxy+camy+24+deltay,6)
 
 -- text
 cursor(5+camx,26+camy+deltay,7)
 print(d)
  
 -- answers
 if(#a>0) print("") -- empty line
 for i=1,#a do
  if i==slct then
   color(12)
   print(">"..a[i])
  else
   color(13)
   print(" "..a[i])
  end
 end
end

-- si path>1 et answer!=path -> add bye
-- si path==1 et pas answer -> no answer
-- si path==0 -> bye/leave

function change_dial()
 slct=1
 if dall[chat]==nil then
  -- nothing to say
  mode=1
 else
  a=aall[chat]==nil and {} or aall[chat][nb]
  path=pall[chat]==nil and {} or pall[chat][nb]
  d=dall[chat][nb]
  a=a or {}
  path=path or {}
  if chat!=4 then -- no answer for thoughts
   local str=chat<4 and "bye" or "(leave)"
   if(#path>1 and #a!=#path) add(a,str)
   if(#path==0) a={str}
  end
 end
end

function start_dial(id)
 mode=2
 chat=id
 nb=1
 -- npc look at the player
 if id<5 then
  for n in all(npc) do
   if(n.id==id) n.f=not p.f
  end
 end
 change_dial()
end
-->8
-- text

-- prolog
dpro={"my name is aNNA bERKELEY. as a\
state alchemist i am known as\
the mud alchemist because\
that's how i once solved a\
murder.",
"the famous rOY mUSTANG, the\
flame alchemist, recently\
summoned me in central city\
because they \"lack smart and\
gorgeous alchemists\".",
"is it a way to tell me to\
investigate something? or is\
it just a game for him?\
i need to figure this out."}

apro={}
ppro={{2},{3}}

dmust1={
"i am glad you came! your desk\
is next to mine. you will\
start by processing some late\
files.",
"i gave my team some well-\
deserved vacations and i told\
them i am capable of managing\
central city by myself. so\
don't tell them you were here.",
"black.",
"i'm all by myself. there is\
also a wanabee alchemist named\
owen locke. and the postwoman\
regularly comes here as well."
}
amust1={{
"why am i really here?",
"of course. do you want a\
coffee as well?",
"who works here? "},
{"who works here?"},
{},
{"why am i really here?"}
}

dcircle={
"you don't know this type of\
transmutation circle, but it\
is sloppy."
}

dbook1={
"    == equivalent exchange ==\
alchemy is the science of\
transmutation. and as all\
science, it follows rules.\
alchemy follows the principle\
of equivalent exchange: in\
order to obtain or create\
something, something or equal\
value must be lost or\
destroyed."
}

dbook2={
"    == alchemy: lesson 4 ==\
transmutation is a sequence\
of three steps:\
- comprehension of the\
  material to be transmuted;\
- deconstruction of the\
  material;\
- reconstruction by bending\
  the material into its new\
  shape.",
"comprehension should not be\
neglected: the learner must\
identify the material he\
wants to know what he needs."
}
pbook2={{2}}

dbook3={
"    == combustion ==\
combustion relies on three\
ingredients:\
- a spark\
- oxygen\
- fuel\
fuel can be wood, alcohol,\
natural gaz, oil,...\
explosives are based on\
phosphorus or sulfur."
}

pmust1={{2,3,4,0},{4,0},{0},{2,0}}

dmust={"first !\nblabla","you said yes","you said no","and so and so"}
dall={dmust1,dpro,dpro,dpro}
amust={{"yes","no"},{"again"},{},{"why?"}}
aall={amust1,apro,apro,apro}

pmust={{2,3,0},{1,0},{4},{1}}
pall={pmust1,ppro,ppro,ppro}

dall[1000]=dbook1
dall[1001]=dbook2
pall[1001]=pbook2
dall[1002]=dbook3
dall[1003]=dcircle
-->8
--draw

function draw_hero()
	local s=180
	if p.o==0 then
  s=176
 elseif p.o==1 then
  s=184
 end
	if(p.x!=p.ox or p.y!=p.oy) s+=flr((4*t())%4)
	spr(s,p.x,p.y-10,1,2,p.o==2)
end

function _draw()
 camx=p.x-60
 camy=p.y-60
 camera(camx,camy)
 cls(0)
 fillp(0)
	
	map()
	local done=false
	for n in all(npc) do
	 if not done and p.y<=n.y*8 then
	  done=true
	  draw_hero()
	 end
	 local nbspr=n.nbspr or n.id
	 if nbspr<4 then
 	 spr(nbspr,n.x*8,n.y*8-10,1,2,n.f==true)
 	else
  	spr(nbspr,n.x*8,n.y*8)
 	end
	end
	if(not done) draw_hero()
	
	if(mode==2)	prt_dial(d,a)
end

__gfx__
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeeeee111eeeeeeeeeeeeeeeee9e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ee0000eee111111eee0000eeee9999e90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e000000eeaaaaaaeee00ffeee99999ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e0000feeeaaaafeaee0fffeee9999fee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e000ffeeeaaaffeeeeffffeee999ffee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeffffeeaeafffeee49494eee999ffee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eefffeeeeefffeeee92222eee999feee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ee1111eeeeddddeee42222eeee9111ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ee1111eeeeddddeeee22f2eeee1111ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ee1171eeeeddfdeeee2222eeee11f1ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ee1111eeeeddddeeee2222eeee1111ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eee442eeeee442eeeeedd1eeeee442ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65555555655555557777777777777777777777777000000077777777000000077000000777777777777777777777777751551115565565562525252500000000
56555555565555556666666666444446dddddddd7000000070000007000000077000000770000000000000000000000711555511556555652555555500000000
55655555556555556666666666411146dddddddd7000000070000007000000077000000770000000000000000000000715555555555656552555555500000000
55565555555655556666666666411146dddddddd7000000070000007000000077000000770000000000000000000000715555555555565552555555500000000
55656555556565556666666666444446dddddddd7000000070000007000000077000000770000000000000000000000755555551555655555252525200000000
56555655524242456666666666244446dddddddd7000000070000007000000077000000770000000000000000000000755555551556565555555255500000000
65555565642424256666666666444446dddddddd7000000070000007000000077000000770000000000000000000000711555511565556555555255500000000
5555555652424246dddddddddd44444d111111117000000070000007000000077000000770000000000000000000000751115515655655655555255500000000
444444444444444444444444111111111111111111111111ebb7bbbeeeeeeeeeeeee3b3e000000000000000000000000515511159eeee88888eeee9e00000000
4444444444dddd44444444441dddddddddddddd11dddddd1e377373eeeeeeeeee33eb4b300000000000000000000000011555511e9e88ee9ee88e9ee00000000
4444444444dddd44444444441dddddddddddddd11dddddd1e337337eeeeeeeee3b33334300000000000000000000000015555555ee8eee9e9eee8eee00000000
4999999949dddd9999999994111111111111111111111111e777737eeeeeeeeeb43b334300000000000000000000000015555555e8eeee9e9eeee8ee00000000
1565655515dddd55551dddd1100223300110440110044221e377737ee949949e3b43b43e00000000000000000000000055555551e8e8e8e8e8e8e8ee00000000
1655565516dddd55561d11d110088bb00cc0990110099881e777773ee994499ee33434be00000000000000000000000059a9a9a18e8e9eeeee9e8e8e00000000
1555556515d55d65651dddd110088bb00cc0990110099881e337373ee949949eee334b330000000000000000000000001a9a9a918e8e9eeeee9e8e8e00000000
1555555615d55d5655111111111111111111111111111111ee3373eee424424ee3b3433e00000000000000000000000059a9a9a58ee8eeeeeee8ee8e00000000
eeeeeeeeeeeeeeeeeeeeeeee100110044022110110330441e949949ee442244eee343eee666666666666666666666666666666668e9e8eeeee8e9e8e00000000
e1111111e11111111111111e100cc0099088cc0110bb0991e994499e9442244eeee4eeee666666666555555667776777666666668e9e8eeeee8e9e8e00000000
e15331c1e17cc1cc77ccc71e100cc0099088cc0110bb0991e949949e9424424eee949eee66666666665666666777677766666636e8e9e8e9e8e9e8ee00000000
e15541c1e1ccc1c77ccc7c1e111111111111111111111111e424424e949949eee99499ee66666666665666666555655566636366e8eeee8e8eeee8ee00000000
e1bbb171e1ccc177ccc7cc1e102204400022033112211331e442244e424424eee49994ee66666666555555556666666666663666ee8eee8e8eee8eee00000000
e1111111e11111111111111e1088099000880bb1188ccbb1e442244e442244eee44444ee66666666666665666667776666553566e9e88ee8ee88e9ee00000000
eeeeeeeeeeeeeeeeeeeeeeee1088099000880bb1188ccbb1e424424e442244eee24442ee666666666666656666677766666656669eeee88888eeee9e00000000
eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111eeeeeeee424424eeee222eee66666666665555566665556666666666eeeeeeeeeeeeeeee00000000
eeeee77777eeeeeeeeeeeeeeeeeeee7777777eeeeeeeeeeeeeeeeee77777eeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eeee7000007eeeeeeee8ee8eeeeee711111117eeeeeeeeeeeeeeee7000007eeeeeeeeeee00000000000000000000000000000000000000000000000000000000
eee700000007eeeeee89aeeeeeeee711111117eeeeeeeeeeeeeee7000fff07eeeeeeeeee00000000000000000000000000000000000000000000000000000000
ee70000000007eeeeee898eeeeee71111111117777eeeeeeeeeee700fffff07eeeeeeeee00000000000000000000000000000000000000000000000000000000
e70000000f0007ee8ee8a98eeeee711111111111117eeeeeeeee700ff1ff1f7eeeeeeeee00000000000000000000000000000000000000000000000000000000
e700000ffff0007eee89a8eeeeee7aaaaaaaaa7777eeeeeeeeee700fffffff7eeeeeeeee00000000000000000000000000000000000000000000000000000000
700000f5ff5f07eee89a8eeeeeee7a9aaafffaa7eeeeeeeeeeee70ffffffff7eeeeeeeee00000000000000000000000000000000000000000000000000000000
e77000ffffff7eeee8a8eeeeeeee7aa9ffafffa77777777eeeeee7ffff55f7e777777eee00000000000000000000000000000000000000000000000000000000
ee700fffffff7eeeee8eeeeeeeee7aaffcafcf7a66666667eeeeee77ffff7e71c11c17ee00000000000000000000000000000000000000000000000000000000
e7077fff55f7eeeeee7eeeeeeeee7aafffffff7767888767eeeee74449944771c11c17ee00000000000000000000000000000000000000000000000000000000
ee77666fff7eeeeeee77eeeeeee7aafff5ffff7767787767eeee799444994441c11c17ee00000000000000000000000000000000000000000000000000000000
ee7611606667eeee7e777eeeeeee7a7fff55f7e766666667eee799994499445655657eee00000000000000000000000000000000000000000000000000000000
e70aaa6161167eee777877eeeeeee7e7ffff7eee77ffff7eee7449994449945655657eee00000000000000000000000000000000000000000000000000000000
70a101a111110770778787eeeeee77777ff7777ee7ffff7eee7444222200225655657eee00000000000000000000000000000000000000000000000000000000
7011101a11111001077877eeeee71111ffff1117ee7ff7eeee799922209289889807eeee00000000000000000000000000000000000000000000000000000000
701111001111101107777eeeee71ddd1ffff1dd1777ff7eee74492220222898898207eee00000000000000000000000000000000000000000000000000000000
7a011111001161111077eeeee71dddd11fff11dd117ff7eee70422220292898898207eee00000000000000000000000000000000000000000000000000000000
7a00111111001611110eeeee71dddd1dd111dd1ddd1ff7ee70220222022223b33b3207ee00000000000000000000000000000000000000000000000000000000
e7a1001111111611660eeeee71ddd1dddd1dddd1dd1ff7ee70222002029223b33b3207ee00000000000000000000000000000000000000000000000000000000
e70aaa0011111166eeeeeeee7f111dddddd1dddd11fff7ee70222220000223b33b32207e00000000000000000000000000000000000000000000000000000000
e70111160011007eeeeeeeee7fff1dddddd1dccd1fff7eeee70022222220ffffff02207e00000000000000000000000000000000000000000000000000000000
e70111161100107eeeeeeeee7fff1d1dddd1dddd1777eeeeee7700022220ffffff02207e00000000000000000000000000000000000000000000000000000000
e70111161116107eeeeeeeee7fff1dd11d1ddd117eeeeeeeeeee70200002222fff7007ee00000000000000000000000000000000000000000000000000000000
e70111161116107eeeeeeeeee7fff1dddd1dddd17eeeeeeeeeee70220222222077e77eee00000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeee77eeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeee7777777997eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeee799999997797eeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee79999fff9977eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee79999ffff997eeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee799999fffff997eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee79999ffffff997eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee79999ffffff997eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee79999fffffff997eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee79999ffffff9997eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee799999ffff99997eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee799999ff9999997eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee799999ff099997eeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee799990ff09997eeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee7999100199907eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee709911111091107eeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee70111111061111107eeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e7011111101161101107eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70111666011116660107eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
701111106111611601107eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
701111101616111610107eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
701101101161111610107eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
701101101111111610107eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
701101011111111610107eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
ee9eeeeeeeeeeeeeee9eeeeeeeeeeeeeeeeeee9eeeeeeeeeeeeeee9eeeeeeee9eeeeee9eeeeeeeeeeeeeee9eeeeeeeee00000000000000000000000000000000
eee999eeee9eeeeeeee999eeee9eeeeeee9999e9eeeeee9eee9999e9eeeeee9eeee999eeeeeeee9eeee999eeeeeeee9e00000000000000000000000000000000
ee99999eeee999eeee99999eeee999eee99999eeee9999e9e99999eeee9999eeee99999eeee999eeee99999eeee999ee00000000000000000000000000000000
ee99999eee99999eee99999eee99999ee9999feee99999eee9999feee99999eeee9fff9eee99999eee9fff9eee99999e00000000000000000000000000000000
ee99999eee99999eee99999eee99999ee999ffeee9999feee999ffeee9999feeee9fff9eee9fff9eee9fff9eee9fff9e00000000000000000000000000000000
ee99999eee99999eee99999eee99999ee999ffeee999ffeee999ffeee999ffeeee9fff9eee9fff9eee9fff9eee9fff9e00000000000000000000000000000000
ee99999eee99999eee99999eee99999ee999feeee999ffeee999feeee999ffeeee99f99eee9fff9eee99f99eee9fff9e00000000000000000000000000000000
ee19991eee99999eee19991eee99999eee9111eee999feeeee9111eee999feeeee91119eee99f99eee91119eee99f99e00000000000000000000000000000000
ee11111eee19991eee11111eee19991eee1111eeee9111eeee1111eeee9111eeee11111eee91119eee11111eee91119e00000000000000000000000000000000
ee11111eee11111eee11111eee11111eee11f1eeee1f11eeee11f1eeee111feeeef111feeef11f1eeef111feee1f11fe00000000000000000000000000000000
ee11111eee11111eee11111eee11111eee1111eeee1111eeee1111eeee1111eeee11111eee22111eee11111eee11144e00000000000000000000000000000000
ee22e44eeeeee44eee22e44eee22eeeeeee442eeee44e22eeee244eeee22e44eee22e44eee22e44eee22e44eee22e44e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeee1c1c1eeeeeeeeee77e777e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeee81c1c1eeeeeeeeee776777e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e55ee77ee8eeeeeeeeeeeeeee77666ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e577e77eee8eeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e577e77eeeeeeeeee022066eeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee77eeeeeeeeeeeee088077eeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeee088077eeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000001000000000000000000000000000000010100010000000000000000010101000000000000000000000000010100000000000000000000000001010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000272233342222223334352222223525000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000272043442020204344452020204525000000000000000000000000000000000027333422222225000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000027202020202020202020202020202500273334333423353334283334222235252743442e2e2e25000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002720203032202031322020202020222222434443442c4543442243442d2d4525272e2e2e292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000027202020202020202020202020202020202c2c2c2c2c2c2c2c2c2d2d2d2d2d33342e2e2e250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002720203132202031322020303220292a2b33342c2c2c333435262d2d2d2d2d43442e2e2e333425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000272020202020202020202020202025002743442c2c2c434445282d2d2d2d2d2e2e2e2e2e434425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000002a2a2a2a212a2a2a2a2a2a2a2a0000272c2c2c2c2c2c2c2c282d2d2d2d2d292b2e2e2e2e2e25000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000100000000000000000000000242424243c2424242424242a2a2a00002a2a2a2a2a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000004949494c494b49494a494c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000494a4949494b49494949490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000004c49494949494b4b49494a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000049494a4a494949494b4b4b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
