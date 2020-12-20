pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- mystery in amestris
-- by cpiod

function _init()
 music(0)
-- o:
-- 0=up, 1=down, 2=left, 3=right
 p={x=8000,y=8000,o=0,f=false}
 camx=title_screen[1].x*8-60
 camy=title_screen[1].y*8-60
 
-- mode:
-- 1: move
-- 2: dialog
-- 3: title screen
-- 4: transmutation
-- 5: fade out
-- 6: fade in
 mode=3
 t11=1 -- 5 circles
 t1=2 -- circle appears
 t2=3 -- go to circle
 t3=4 -- lines begin to appear
 t4=8 -- go to center
 t5=9 -- at center
 t6=11 -- the end
 
 palt(0,false)
	palt(14,true)
	
 tele={{x1=45,y1=22,x2=115,y2=9,o=3},
 {x2=45,y2=22,x1=115,y1=9,o=2},
 {x1=8,y1=13,x2=94,y2=13,o=0},
 {x2=8,y2=13,x1=94,y1=13,o=1},
 {x1=60,y1=5,x2=106,y2=27,o=0},
 {x2=60,y2=5,x1=106,y1=27,o=1}}
	sort(npc)
end

function _update60()
 if mode==1 then
  update_move()
 elseif mode==2 then
  update_diag()
 elseif mode==3 or mode==7 then
  update_title()
 elseif mode==4 then
  update_circle()
 end
end

function update_diag()
 if(btnp(⬆️) and slct>1) slct-=1
 if(btnp(⬇️) and slct<#a) slct+=1
 if btnp(🅾️) then
  nb=path[slct]
  if nb==0 or nb==nil then
   mode=1
  else
   change_dial()
  end
 end
 if(btnp(❎) and not st_final_dial and chat!=1037) mode=1
end

function update_move()
 if not st_secret_room and p.x==116*8 and p.y==9*8 then
  st_secret_room=true
  add(aall[4][1],
"i know about the secret room\
with all the bottles.",2)
  add(pall[4][1],13,2)
 end

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
    if(tp.o==0) p.oy=p.y-8 p.ox=p.x
    if(tp.o==1) p.oy=p.y+8 p.ox=p.x
    if(tp.o==2) p.ox=p.x-8 p.oy=p.y
    if(tp.o==3) p.ox=p.x+8 p.oy=p.y
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
	 -- check front to back
	 for i=#npc,1,-1 do
	  local n=npc[i]
	 -- npc in path: stop moving, start chatting
	  if not fget(n.nbspr,0) and n.x==x/8 and n.y==y/8 then
	   mov=false
	   if(n.id!=nil) start_dial(n.id)
	   break
	  end
	 end
	 if(not mov or not fget(mget(x/8,y/8),0)) x,y=p.x,p.y
	 p.ox,p.oy=x,y
 end
 camx=p.x-60
 camy=p.y-68
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

faces={80,83,86,89,92}
faces[9]=128
names={"rOY mUSTANG\
flame alchemist",
"aMELIA sMITH\
postwoman",
"oWEN lOCKE\
apprentice",
"vICTOR gREY\
mail manager",
"mRS. cALVIN\
librarian"}
local s="a book"
names[1000]=s
names[1001]=s
names[1002]=s
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
 local i_d=cnt(d)
 local i=i_d
 for t in all(a) do
  i+=cnt(t)
 end
 if(#a>0) i+=1
 local maxy=8+6*(i+#a)
 local deltay=98-maxy
 local namex=5
 -- name
 local f=faces[chat]
 if(chat>=900 and chat<1000) f=faces[9]
 if f!=nil then
  namex+=20
  spr(f,camx+5,camy+deltay,3,3)
  if(chat<900) spr(128,camx+98,camy+deltay,3,3,true)
 end
 names[chat]=names[chat] or ""
 local namey=cnt(names[chat])*6
 for i=-1,1 do
  for j=-1,1 do
   print(names[chat],camx+namex+i,camy+deltay+18+j-namey,0)
  end
 end
 print(names[chat],camx+namex,camy+deltay+18-namey,6)
 
 -- bg
 rectfill(3+camx,24+camy+deltay,125+camx,maxy+camy+24+deltay,1)
 rect(3+camx,24+camy+deltay,125+camx,maxy+camy+24+deltay,6)
 
 -- text
 local x=5+camx
 local y=26+camy+deltay
 print(d,x,y,7)
 y+=(i_d+2)*6
 -- answers
 for i=1,#a do
  if i==slct then
   color(12)
   print(">"..a[i],x,y)
  else
   color(13)
   print(" "..a[i],x,y)
  end
  y+=6+6*cnt(a[i])
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
  chat2,nb2=check_update(chat,nb)
  if(mode!=2) return
  chat=chat2 or chat
  nb=nb2 or nb
  a=aall[chat]==nil and {} or aall[chat][nb]
  path=pall[chat]==nil and {} or pall[chat][nb]
  d=dall[chat][nb]
  a=a or {}
  path=path or {}
  if chat<900 or chat>=1000 then -- no answer for thoughts
   local str=chat<10 and "bye" or "(leave)"
   if(#path>1 and #a!=#path) add(a,str)
   if(#path==0) a={str}
  end
 end
end

function start_dial(id,nbp)
 mode=2
 chat=id
 nb=nbp or 1
 -- npc look at the player
 if p.o>=2 and id<10 and id!=5 then -- no the old lady
  for n in all(npc) do
   if(n.id==id) n.f=not p.f
  end
 end
 change_dial()
end
-->8
-- text
dall={}
pall={}
aall={}

-- prolog
names[900]="aNNA bERKELEY"
for i=901,999 do
 names[i]=names[900]
end

dall[900]={"my name is aNNA bERKELEY. as a\
state alchemist i am known as\
the eagle-eyed alchemist\
because i once solved a\
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
pall[900]={{2},{3}}

dall[901]={"i should see mUSTANG first."}

dall[902]={
"i won't leave until i sorted\
this out."}

dall[903]={
"i don't feel like gardening."}

dall[904]={"the flag of amestris. classy."}

dall[905]={"the flag of amestris. classy.",
"wait... there is something\
behind! i'll toss the flag."}
pall[905]={{2}}
aall[905]={{"(look closer)"}}


names[906]="some bottles"
dall[906]={
"\"l'authentique bouteille de\
vin.\"\
sounds fancy. i am pretty sure\
alcohol is forbidden here... \
it probably belongs to the\
mail manager, vICTOR gREY."}


-- mustang
dall[1]={
"i am glad you came! your desk\
is in the next room. you will\
start by processing some late\
files.",
"i gave my team some well-\
deserved vacations and i told\
them i am capable of managing\
central city by myself. so\
don't tell them you were here.",
"yes. with milk and one sugar\
cube.",
"i'm all by myself. there is\
also a wanabee alchemist named\
oWEN lOCKE. mRS. cALVIN is\
certainly in the library. and\
i guess our mail manager,\
vICTOR gREY, is nearby.",
"right. what do you want?",
"i'd never ask for such a book.\
as gRUMMAN says, i would not\
need it. the best i can say is\
that somebody used my name to\
get it.",
"wow. i didn't think you would\
actually do it, you know.",
"no.",
"ok... but only because you\
brought me coffee.",
-- 10
"great, you wake up. you\
trigger the explosive that\
was hidden in a box. gladly,\
owen did install a protective\
transmutation circle with the\
red trees. this is impressive\
work. victor grey is injured\
but should be yelling at us\
soon, as usual.",
"now, you need to tell us what\
you know. where do the\
explosives comes from?",
"probably not. the packages\
are verified by mRS. cALVIN\
and vICTOR gREY.",
"that's also what i think.",
"who do you think did it?",
"yes, it was. but anybody\
could have read her book.\
oWEN did it.",
"certainly. and he got the\
transmutation circle from\
the book mRS. cALVIN gave him.",
"no, he isn't that bad. and\
he doesn't know how to\
transmute.",
"how could i save someone from\
an explosion? that's\
ridiculous.",
"yeah, sure.",
"why did he do that?",
"i'm not sure why you would\
think that.",
"it's unlikely. he doesn't\
want to harm anybody.",
"yes, certainly. with an\
explosion, he could show me\
this giant transmutation\
circle with the trees.",
"congratulations! you solved\
the case. thank you very much\
for your help.\
\
i still want you to process\
the late files as soon as\
you go out of bed, though.",
"maybe you should have pay\
more attention...",
"i don't think he is looking\
for her attention."
}
aall[1]={{
"of course. do you want a\
coffee as well?",
"i won't go until i have\
answers."
},
{},
{},
{},
{"who works here?",
"why am i really here?"},
{},
{},
{},
{},
{}, --10
{"they were delivered through\
packages.",
"they were transmuted in the\
secret room of the library"},
{},
{},
{"mRS. cALVIN, because it was\
her transmutation circle.",
"oWEN lOCKE, because\
fertilizer is an ingredient\
of the transmutation.",
"vICTOR gREY, because he\
wants to kill every alchemist.",
"aMELIA sMITH, because she\
wanted you to save her.",
"you, because no one expects\
the good guy of the anime to\
be evil in a fangame."},
{},
{},
{},
{},
{},
{"to kill me.",
"to kill vICTOR gREY.",
"to impress you.",
"to impress mRS. cALVIN."}
}
pall[1]={
{3,5},
{5},
{},
{5},
{4,2,0},
{},
{},
{},
{},
{11},--10
{12,13},
{14},
{14},
{15,16,17,18,19},
{20},
{20},
{25},
{25},
{25},
{21,22,23,26},
{25},
{25},
{24},
{200},
{200},
{25}
}

dall[2]={
"i didn't do anything wrong!",
"what do you want?",
"nothing at all! i mean...\
mustang is really handsome,\
isn't he? you don't have a\
photo of him, by any chance?",
"wow... thank you! how did\
you...? never mind. thanks\
again. i should go now!",
"too bad...",
"he looks at me in a creepy\
way. don't look at me like\
this! it's totally different\
from what i do with mUSTANG.",
"no, i swear! i always did my\
job with great\
conscientiousness."
}

aall[2]={
{"i didn't say anything."},
{"what are you doing here?",
"what do you think of the mail\
manager?",
"do you know something about\
missing packages?"},
{"what? no!"},
{},
{}}

pall[2]={
{2},
{3,6,7,0},
{5},
{100},
{0},
{2},
{2}}

-- owen locke
dall[3]={
"welcome to my greenhouse! my\
name is owen lock. i am still\
an apprentice: i work on the\
interactions between plants\
and alchemy.",
"with pleasure! as you know,\
alchemy is based on the\
telluric energy that comes\
from deep inside the earth.\
plants also harvest this\
energy; but something is\
wrong... my experiments keep\
failing, even though i am sure\
my theory is correct.",
"as soon as my experiments\
work. i could pass the exam\
now, but i want to work with\
rOY mUSTANG and learn his\
alchemy. to do that, i must\
impress him first.",
"i don't know yet. something\
classy. do you have an idea?",
"no. ask amelia, the postwoman.\
she seems to wander nearby\
very often even though that's\
not her place. i find her very\
suspicious.",
"that's... something. well, i\
need to go back to my\
experiments now.",
"yeah... yeah! that's awesome.\
tellurician, because my\
research is about telluric\
energy. thanks for the tip.\
here is some advice for your\
little mail investigation:\
there is an hidden door in\
the right wall of the lower\
package room. look for a grey\
wall.",
"too bad.",
"no. he is rude and he doesn't\
respect the alchemists.",
"she is a wonderful lady.\
skillful and mischievous.\
don't let her old age fool\
you: she is very powerful.",
"what do you want?"
}

aall[3]=
{{},
{"when will you try the state\
alchemist exam?"},
{"what will be your state\
alchemist codename?"},
{"the mad gardener",
"the tellurician",
"the soil-eater",
"no."},
{},
{},
{},
{},
{},
{},
{"tell me more about your\
research",
"do you like the mail manager?",
"do you know the librarian?"
}
}

pall[3]={
{11},
{3},
{4},
{6,7,6,8},
{11},
{},
{},
{},
{11},
{11},
{2,9,10,0},
}

-- victor grey
dall[4]={"i'm busy. go away.",
"packages are missing! three\
of them so far. that's\
unacceptable. my reputation is\
at stake, do you understand?",
"well, you can stay here day\
and night and catch the thief\
if he ever comes back.",
"amelia, the postwoman? she is\
a nice girl. far more clever\
that she sounds. she managed\
to bring the mail here to see\
me more often. i think she\
likes me.",
"rOY mUSTANG. he told me\
that's nothing, that he\
doesn't even remember what\
these packages were. but i\
can tell when he lies. he\
considers it is a big problem.",
"i mean... that's possible, of\
course. but i don't think so.\
she has always been honest\
with me. that's a rare\
quality.",
"i don't see him much. always\
working in his greenhouse,\
night and day. he received\
lots of fertilizer, recently.\
probably for his experiments.\
he wants to impress mUSTANG\
but the colonel doesn't give\
him much attention.",
"no. i don't trust alchemists.\
especially state alchemists.\
and he is too flirtatous with\
ladies.",
"beware the old mrs. calvin:\
she was once a powerful\
alchemist. she is very nice,\
but don't angry her by not\
returning your books to the\
library. she is probably the\
least unbearable state\
alchemist. she is secretive.\
i think there is an hidden\
room somewhere in her\
library...",
"and that's why i hate state\
alchemists.",
"no. but i registered them\
when they arrived. one came\
from a library from east city.\
it was an alchemy book about\
explosives, addressed to\
mUSTANG. the second one came\
in a bag. i didn't open it;\
maybe electrial wire or ropes?\
the last was a letter\
addressed to mUSTANG.",
"it doesn't mean your time is\
worth more than mine.",
"okay. i can maybe give you two\
minutes of my time.",
"what to you want?"
}

aall[4]={
{"i am a state alchemist!"},
{"can i help you?",
"who were the missing packages\
addressed to?"},
{},
{"she seems to prefer mUSTANG.",
"do you think she could be the\
thief?"},
{"so nobody knows what was\
inside these packages?"},
{},
{},
{},
{},
{},
{},
{},
{},
{"you seem worried.",
"do you know the blonde girl?",
"what do you think of the\
apprentice?",
"do you know mUSTANG well?",
"what can you tell me about\
the librarian?"}
}

pall[4]={
{12,0},
{3,5},
{},
{10,6},
{11},
{14},
{14},
{14},
{14},
{},
{14},
{},
{14},
{2,4,7,8,9,0},
}

dall[5]={
"hello, dear! it's rare to see\
a new face around here.",
"what are you interested in?",
"why the past tense? i am\
still a powerful alchemist!\
specialized in all kind of\
explosives. in fact, i still\
help victor to verify that\
the packages we received are\
not booby-trapped.",
"he is very ambitious, yet he\
is a good leader. but don't\
trust him too much.",
"of course! he could not harm\
anyone. he is very sweet with\
everyone and he brings me\
cookies once in a while. i\
love to chat with him. i even\
offered him one of my books.",
"i call him grumpy, he calls\
me an old bat. we like each\
other.\
he is secretive. did you know\
he has a secret room?",
"oh, dear! where was it?",
"he is so forgetful! it's a\
rare book about large scale\
transmutation. thank you for\
bringing it back. how can i\
thank you? i know! here: take\
this alchemy-fueled camera!\
it's an expansive gift.",
"before doing that, you'd have\
to tell me all about your\
interests. only then i could\
make a relevant recommendation\
for you."
}
aall[5]={
{},
{"can you recommend me a book?",
"i was told you were a\
powerful alchemist.",
"what do you think of mustang?",
"should i trust the\
apprentice?",
"do you like the mail manager?"
},
{},
{},
{},
{},
{"in oWEN's room."},
{"thank you!"},
{"let's not do that."}
}

pall[5]={
{2},
{9,3,4,5,6,0},
{2},
{2},
{2},
{2},
{8},
{},
{2}
}

dall[1000]={"  == equivalent exchange ==\
\
alchemy is the science of\
transmutation. and as all\
science, it follows rules.\
alchemy follows the principle\
of equivalent exchange: in\
order to obtain or create\
something, something of equal\
value must be lost or\
destroyed."}

dall[1001]={
"  == alchemy: lesson 4 ==\
\
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
wants to know what\
ingredients he needs."
}
pall[1001]={{2}}

dall[1002]={
"to oWEN lOCKE,\
i wish you a great future.\
and don't let mUSTANG annoy\
you.\
\
             aMANDA cALVIN",
"  == combustion ==\
\
combustion relies on three\
ingredients:\
- a spark\
- oxygen\
- fuel\
fuel can be wood, alcohol,\
natural gas, oil,...\
explosives are based on\
phosphorus or sulfur."
}
pall[1002]={{2}}

names[1003]="a gray book"
dall[1003]={
"that's the gray book that is\
missing!"}

names[1004]="a key"
dall[1004]={
"you find a key. certainly a\
master key.\
\
you take it with you."}

names[1005]="a key"
dall[1005]={
"you find an old rusty key.\
\
you take it with you."}

names[1006]=""
dall[1006]={"she went away, smiling."}


names[1010]="a note on the entrance"
dall[1010]={
"alchemy library\
\
return your books in time or\
suffer my wrath.\
\
mRS. cALVIN"}

names[1011]="some papers"
dall[1011]={
"!!! wanted !!!\
\
i am a gray book. i\
disappeared a few days ago. if\
you find me, return me!\
\
(no ransom)"}

names[1012]="a sealed letter"
dall[1012]={
"rOY,\
\
i don't know why you seem\
so interested in books about\
explosive transmutation. you\
should probably be the one\
writing them. anyway: be\
careful. i don't know what\
you need that for, but some\
people are suspicious.\
\
gRUMMAN","you take it."}
pall[1012]={{2}}

names[1013]="an ad"
dall[1013]={
"get a dream body with 1 tip!\
\
1. don't trust advertisements"}

names[1014]="a pile of files"
dall[1014]={
"a very high pile of the files."}

names[1015]="a note on the wall"
dall[1015]={"if i'm not here, ring the\
bell.\
\
v.gREY.\
ps: there is no bell."}

names[1016]="a pile of receipts"
dall[1016]={"nothing interesting here."}

names[1017]="some drawings"
dall[1017]={"a sketch of a transmutation\
circle based on a pentagram\
and some drawings of trees."}

names[1020]="a window"
dall[1020]={
"you see some trees outside."}

names[1021]="someone?"
dall[1021]={
"there is someone behind the\
window. as soon as she sees\
you, she hides."}

names[1022]="a grey book"
dall[1022]={
"i have no reason yet to check\
this book."}

names[1023]="a sack of fertilizer"
dall[1023]={
"that's fertilizer. lot of it.\
i guess someone is not very\
good at gardening..."}

names[1024]="a sign"
dall[1024]={
"greenhouse\
\
experiments in progress,\
proceed with caution."}

names[1025]="a door"
dall[1025]={"it's locked."}

names[1026]="a transmutation circle"
dall[1026]={
"you recognize this\
transmutation circle from\
the book of mRS. cALVIN. it\
is used to transmute\
explosives!\
\
you prefer not to walk over\
it."}

names[1027]="a tree"
dall[1027]={"...\
\
it has nothing to say."}

names[1028]="a sign"
dall[1028]={"the boxes will go away.\
eventually.\
\
v.gREY"}

names[1029]="some ash"
dall[1029]={"a small pile of cold ash."}

names[1030]="some food"
dall[1030]={"it doesn't smell good. cheese\
maybe?"}

names[1031]="a door"
dall[1031]={"the master key unlocks the\
door!"}

names[1032]="a door"
dall[1032]={
"it's locked."}

names[1033]="a door"
dall[1033]={
"it's locked."}

names[1034]="a door"
dall[1034]={"the old key unlocks the door!"}

names[1035]="a crowbar"
dall[1035]={
"that crowbar can be useful.\
why not take it?"}

names[1036]="a heavy box"
dall[1036]={
"that wood seems breakable. with\
some tool, you could open it."}

names[1037]="a heavy box"
dall[1037]={
"you open the box with the\
crowbar. it explodes!",""}
aall[1037]={{"die?"}}
pall[1037]={{2}}

names[1038]="an alchemy-fueled\
coffee machine"
dall[1038]={
"coffee?",
"milk?",
"sugar?",
"sugar?",
"caution: it's hot.",
"caution: it's hot.",
"you remember you hate coffee.",
"just like mUSTANG likes it."}
aall[1038]={
{"yes","no"},
{"yes","no"},
{"no","one sugar cube","two sugar cubes"},
{"no","one sugar cube","two sugar cubes"},
}
pall[1038]={
{2},
{4,3},
{5,5,5},
{5,5,5},
{7},
{8}
}
-->8
-- draw

function draw_hero()
	local s=11
	if p.o==0 then
  s=7
 elseif p.o==1 then
  s=208
 end
	if(mode==1 and (p.x!=p.ox or p.y!=p.oy)) s+=flr((4*t())%4)
	spr(s,p.x,p.y-10,1,2,p.o==2)
end

function _draw() 
 camera(camx,camy)
 cls(0)	
 
	map(0,0)
	local done=st_final_dial
	-- no draw_hero in final dialogue
	for n in all(npc) do
	 if not done and p.y<=n.y*8 then
	  done=true
	  draw_hero()
	 end
	 local nbspr=n.nbspr or n.id
	 if nbspr>15 then
	  spr(nbspr,n.x*8,n.y*8,1,1,n.f==true)
  elseif nbspr>=0 then
	  if n.f=="up" then
	   spr(6,n.x*8,n.y*8-10,1,2)
	  else
 	  spr(nbspr,n.x*8,n.y*8-10,1,2,n.f==true)
 	 end
 	else
 	end
	end
	if(not done) draw_hero()

	if(mode==2 and chat==1037) draw_fire()
	
	if(mode==2)	prt_dial(d,a)
	
	if mode==7 or mode==3 then
	 spr(198,camx+100,camy+9,3,3)
	 spr(247,camx+108,camy+9+3*8)
	 sspr(72,104,7*8,3*8,camx+1,camy+10,7*8*2,3*8*2)
	 if mode==3 then
		 if t()%1<.8 then
	   print_center("press z to investigate",camx,camy+90,8)
	  end
	 else
	  print_center("the game is over",camx,camy+70,12)
	  print_center("i hope you liked it!",camx,camy+76,12)
  end
	 local t="cpiod - 2020"
  print_center(t,camx,camy+120,1)
	
	elseif mode==4 then
  draw_fire()
  draw_circle()

	elseif mode==5 then
  draw_circle(true)
	 chat=-1
 	a={}
	 d="the fire is out but you faint\
because of the smoke."
	 prt_dial()
  fade={[0]=0,0,0,0,1,0,5,6,2,2,4,3,5,1,4,4}
  m=t()-t0
  for i=0,15 do
   if m<2.1 then
    c=i
   elseif m<2.2 then
    c=fade[i]
   elseif m<2.3 then
    c=fade[fade[i]]
   elseif m<5 then
    c=fade[fade[fade[i]]]
   else
    c=fade[fade[fade[i]]]
    mode=6
    t0=t()
    mset(109,27,182)
    mustang.x=108
    mustang.y=27
    mustang.f=false
    locke.x=109
    locke.y=26
    locke.f=true
    calvin.x=105
    calvin.y=26
    calvin.f=false
    calvin.id=15
    sort(npc)
    p.x=109*8
    p.y=28*8
    p.ox=p.x
    p.oy=p.y
    camx=p.x-60
    camy=p.y-68
    st_final_dial=true
   end
   pal(i,c,1)
  end
	
	elseif mode==6 then
  fade={[0]=0,0,0,0,1,0,5,6,2,2,4,3,5,1,4,4}
  m=t()-t0
  for i=0,15 do
   if m<.3 then
    c=fade[fade[fade[i]]]
   elseif m<.6 then
    c=fade[fade[i]]
   elseif m<.9 then
    c=fade[i]
   elseif m<2 then
    c=i
   else
    c=i
    start_dial(1,10)
   end
   pal(i,c,1)
  end
	end
end

function print_center(t,x,y,c)
	for i=-1,1 do
	 for j=-1,1 do
  	print(t,x+(64-4*(#t/2))+i,y+j,0)
  end
 end
 print(t,x+(64-4*(#t/2)),y,c)
end
-->8
-- npc/status
 npc={
 -- ordered back to front
 
 -- flags
 {nbspr=54,id=904,x=40,y=1},
 {nbspr=54,x=28,y=23}, -- behind
 {nbspr=54,x=30,y=23},
 {nbspr=54,id=904,x=15,y=13},
 {nbspr=54,id=904,x=23,y=17},
 {nbspr=54,id=904,x=25,y=13},
 {nbspr=54,id=904,x=27,y=13},
 {nbspr=54,id=904,x=32,y=6},
 {nbspr=54,id=904,x=35,y=6},
 {nbspr=54,id=904,x=22,y=2},
  
 -- outside door
 {nbspr=58,x=29,y=23}, 

 -- windows
 -- mustang window
 {nbspr=64,id=1020,x=33,y=6},
 {nbspr=66,x=34,y=6},
 -- postwoman window
 {nbspr=65,id=1021,x=32,y=13},
 {nbspr=66,x=33,y=13},
 -- alchemist room
 {nbspr=65,x=19,y=2},
 {nbspr=66,x=20,y=2},
 {nbspr=65,x=24,y=2},
 {nbspr=66,x=25,y=2},

 -- sheets on wall
-- secret room
 {nbspr=240,id=1013,x=120,y=7,f=true},
-- warehouse
 {nbspr=240,x=41,y=12},
 {nbspr=240,id=1015,x=46,y=12,f=true},
-- library entrance
 {nbspr=240,id=1010,x=22,y=17},
  
  
 -- fertilizer
 {nbspr=166,id=1023,x=48,y=4},
 {nbspr=167,id=1023,x=38,y=6},
 {nbspr=167,id=1023,x=43,y=4,f=true},
 {nbspr=168,id=1023,x=60,y=8},
 {nbspr=168,id=1023,x=42,y=5,f=true},

  
 -- outside boxes
 {nbspr=71,x=42,y=10},
 {nbspr=55,x=42,y=9},
 {nbspr=71,x=64,y=5},
 {nbspr=55,x=64,y=4},
 {nbspr=55,x=42,y=5},
 {nbspr=71,x=42,y=6},
 {nbspr=70,x=32,y=15},
 {nbspr=70,x=42,y=7},
 {nbspr=70,x=42,y=4},
 {nbspr=70,x=53,y=2},
 {nbspr=70,x=57,y=2},

 {nbspr=70,x=28,y=14},
 {nbspr=70,x=29,y=16},
 {nbspr=70,x=30,y=15},
 {nbspr=70,x=31,y=17},
 {nbspr=70,x=32,y=18},

 {nbspr=71,x=30,y=14},
 {nbspr=71,x=33,y=17},
 {nbspr=71,x=26,y=20},
 {nbspr=71,x=31,y=16},
 {nbspr=55,x=30,y=13},
 {nbspr=55,x=33,y=16},
 {nbspr=55,x=26,y=19},
 {nbspr=55,x=31,y=15},

 -- circle
 {nbspr=61,id=1026,x=93,y=8},
 {nbspr=61,id=1026,x=91,y=11},
 {nbspr=61,id=1026,x=95,y=11},

 {nbspr=62,id=1026,x=94,y=8},
 {nbspr=62,id=1026,x=92,y=11},
 {nbspr=62,id=1026,x=96,y=11},

 {nbspr=77,id=1026,x=93,y=9},
 {nbspr=77,id=1026,x=91,y=12},
 {nbspr=77,id=1026,x=95,y=12},

 {nbspr=78,id=1026,x=94,y=9},
 {nbspr=78,id=1026,x=92,y=12},
 {nbspr=78,id=1026,x=96,y=12},

 -- desk
 {nbspr=163,x=106,y=25},
 {nbspr=164,x=107,y=25},
 
 {nbspr=48,x=34,y=8,f=true},
 {nbspr=48,x=25,y=6,f=true},
 {nbspr=48,x=24,y=4},
 {nbspr=48,x=20,y=6},
 {nbspr=48,x=17,y=8,f=true},
 
 {nbspr=49,x=16,y=6},
 {nbspr=49,x=21,y=4,f=true},
 {nbspr=49,x=20,y=8},
 {nbspr=49,x=24,y=8},
  
 {nbspr=50,x=33,y=8,f=true},
 {nbspr=50,x=25,y=4},
 {nbspr=50,x=24,y=6,f=true},
 {nbspr=50,x=25,y=8},
 {nbspr=50,x=20,y=4,f=true},
 {nbspr=50,x=21,y=6},
 {nbspr=50,x=21,y=8},
 {nbspr=50,x=17,y=6},
 {nbspr=50,x=16,y=8,f=true},
 
 {nbspr=49,x=118,y=8},
 {nbspr=149,x=119,y=8},
 {nbspr=133,x=119,y=7},
 {nbspr=163,x=19,y=17},
 {nbspr=164,x=20,y=17},
 {nbspr=163,x=42,y=13},
 {nbspr=164,x=43,y=13},

 -- boxes
 {nbspr=70,x=116,y=8},
 {nbspr=70,x=117,y=10},
  
 {nbspr=70,x=40,y=20},
 {nbspr=70,x=43,y=19},
 {nbspr=70,x=44,y=20},
 {nbspr=70,x=38,y=21},
 {nbspr=70,x=41,y=21},
 {nbspr=197,id=1036,x=44,y=15},
 {nbspr=197,x=92,y=8},
 {nbspr=71,x=38,y=19},
 {nbspr=71,x=42,y=20},
 {nbspr=71,x=39,y=22},
 {nbspr=71,x=43,y=15},
 {nbspr=55,x=38,y=18},
 {nbspr=55,x=42,y=19},
 {nbspr=55,x=39,y=21},
 {nbspr=55,x=43,y=14},
  
 -- table
 {nbspr=165,x=10,y=23},
 {nbspr=165,x=120,y=10},
 {nbspr=165,x=5,y=17},
 {nbspr=165,x=108,y=28},
 {nbspr=165,x=97,y=12},
 
  -- ash
 {nbspr=140,id=1029,x=52,y=5,f=true},
 {nbspr=140,id=1029,x=97,y=12},
 
 -- chairs
 {nbspr=171,x=104,y=26,f=true},
 {nbspr=137,x=36,y=9},
 {nbspr=171,x=41,y=13,f=true},
 {nbspr=171,x=6,y=17},
 {nbspr=171,x=11,y=23},
 {nbspr=171,x=57,y=8,f=true},
 
 -- wine
 {nbspr=-1,id=906,x=119,y=8},

-- office book
 {nbspr=241,id=1000,x=17,y=8},
-- librarian book
 {nbspr=241,id=1001,x=5,y=17},
-- book in greenhouse
 {nbspr=241,id=1002,x=107,y=25},
  
 -- paper
-- work from mustang
 {nbspr=243,id=1014,x=25,y=6},
-- desk of mail manager
 {nbspr=243,id=1016,x=43,y=13},
-- library entrance
 {nbspr=243,id=1011,x=19,y=17},
-- greenhouse
 {nbspr=243,id=1017,x=58,y=8},
 
 -- watering
 {nbspr=155,id=903,x=56,y=4},

 -- greenhouse sign
 {nbspr=-1,id=1024,x=53,y=10},
 -- greenhouse sign
 {nbspr=-1,id=1028,x=33,y=18},
 -- front door
 {nbspr=-1,id=902,x=29,y=23},
  
 -- dynamite
 {nbspr=246,x=97,y=11},
 {nbspr=246,x=91,y=8,f=true},
  
 -- plants
 {nbspr=142,x=59,y=7},
 {nbspr=158,x=59,y=8},
 {nbspr=142,x=50,y=6,f=true},
 {nbspr=142,x=55,y=6},
 {nbspr=158,x=50,y=7,f=true},
 {nbspr=174,x=55,y=7},
 {nbspr=156,x=50,y=4,f=true},
 {nbspr=156,x=53,y=6},
 {nbspr=172,x=50,y=5,f=true},
 {nbspr=172,x=53,y=7},

 {nbspr=141,x=51,y=4},
 {nbspr=157,x=53,y=4},
 {nbspr=141,x=52,y=6,f=true},

 {nbspr=173,x=51,y=5},
 {nbspr=173,x=53,y=5},
 {nbspr=173,x=52,y=7,f=true},

 {nbspr=38,id=1038,x=42,y=13},
 {nbspr=248,x=42,y=12},
 
 -- trees
 {nbspr=56,x=91,y=6},
 {nbspr=72,x=91,y=7},

 {nbspr=56,x=38,y=1},
 {nbspr=138,x=38,y=2},
 {nbspr=95,x=39,y=1},
 {nbspr=138,x=39,y=2},
 {nbspr=95,x=57,y=9},
 {nbspr=138,x=57,y=10},
 {nbspr=56,x=105,y=24},
 {nbspr=72,x=105,y=25},

 {nbspr=56,x=63,y=11},
 {nbspr=138,x=63,y=12},
 {nbspr=56,x=57,y=5},
 {nbspr=72,x=57,y=6},
 {nbspr=95,x=58,y=5},
 {nbspr=72,x=58,y=6},
 {nbspr=56,x=59,y=5},
 {nbspr=111,x=59,y=6},
 {nbspr=56,x=7,y=16},
 {nbspr=72,x=7,y=17},

 -- left part of the greenhouse
 -- top row
 {nbspr=56,x=44,y=3,f=true},
 {nbspr=72,x=44,y=4},
 {nbspr=95,x=45,y=3,f=true},
 {nbspr=72,x=45,y=4},
 {nbspr=56,x=46,y=3},
 {nbspr=111,x=46,y=4},
 {nbspr=95,x=47,y=3,f=true},
 {nbspr=111,x=47,y=4},
 
 -- middle row
 {nbspr=56,x=43,y=5,f=true},
 {nbspr=72,x=43,y=6},
 {nbspr=95,x=44,y=5,f=true},
 {nbspr=111,x=44,y=6},
 {nbspr=56,x=45,y=5},
 {nbspr=72,x=45,y=6},
 {nbspr=95,x=47,y=5},
 {nbspr=72,x=47,y=6},

 -- low row
 {nbspr=56,x=43,y=7},
 {nbspr=111,id=1027,x=43,y=8},
 {nbspr=95,x=45,y=7},
 {nbspr=111,x=45,y=8},
 {nbspr=95,x=46,y=7},
 {nbspr=72,x=46,y=8},
 {nbspr=56,x=47,y=7,f=true},
 {nbspr=72,x=47,y=8},
 
 {nbspr=95,x=27,y=7},
 {nbspr=72,x=27,y=8},
 {nbspr=56,x=46,y=14},
 {nbspr=72,x=46,y=15},
 {nbspr=95,x=31,y=6},
 {nbspr=111,x=31,y=7},
 {nbspr=95,x=18,y=16},
 {nbspr=72,id=1027,x=18,y=17},
 {nbspr=56,x=15,y=2},
 {nbspr=111,x=15,y=3},
  
 -- red trees
 {nbspr=190,x=36,y=6},
 {nbspr=206,x=36,y=7},
 {nbspr=191,x=49,y=6},
 {nbspr=206,x=49,y=7},
 {nbspr=191,x=34,y=14},
 {nbspr=207,x=34,y=15},
 {nbspr=190,x=43,y=21},
 {nbspr=206,x=43,y=22},
 {nbspr=190,x=51,y=14,f=true},
 {nbspr=207,x=51,y=15}
 }
  
 st_secret_room=false
 st_key_g=false
 st_key_l=false
 st_white_b=false
 st_flag=false
 st_lost_pkg=false
 st_crowbar=false
 st_final_dial=false
 st_letter=false
 st_missing=false
 st_know_wbook=false
 st_camera=false
 st_coffee=false -- given to mustang

 -- npc
 mustang={id=1,x=34,y=9}
 add(npc,mustang)
 calvin={id=5,x=9,y=23}
 add(npc,calvin)
 amelia={id=2,x=32,y=14,f="up"}
 add(npc,amelia)
 grey={id=4,x=45,y=13,f=true}
 add(npc,grey)
 locke={id=3,x=55,y=5}
 add(npc,locke)

 letter={nbspr=244,id=1012,x=117,y=10}
 add(npc,letter)
 key_g={nbspr=245,id=1004,x=120,y=10}
 add(npc,key_g)
 key_l={nbspr=245,id=1005,x=31,y=14}
 add(npc,key_l)
 door_g={nbspr=-1,id=1025,x=60,y=5}
 add(npc,door_g)
 door_g2={nbspr=-1,id=1032,x=49,y=3}
 add(npc,door_g2)
 door_l={nbspr=-1,id=1033,x=8,y=13}
 add(npc,door_l)
 flag_l={nbspr=54,id=905,x=8,y=13}
 add(npc,flag_l)
 wbook={nbspr=242,id=1022,x=109,y=25}
 add(npc,wbook)
 crowbar={nbspr=181,id=1035,x=97,y=8}
 add(npc,crowbar)

 f1={nbspr=54,id=904,x=41,y=9}
 f2={nbspr=54,id=904,x=41,y=18}
 f3={nbspr=54,id=904,x=37,y=13}
 add(npc,f1)
 add(npc,f2)
 add(npc,f3)

function check_update(chat,nb)
 if chat==1 and nb==200 then
  mode=7
  music(27)
  p={x=8000,y=8000,o=0,f=false}
  camx=title_screen[1].x*8-60
  camy=title_screen[1].y*8-60
 elseif not st_missing and chat==4 and nb==2 then
  st_missing=true
  add(aall[3][11],"do you know anything about\
some missing mail?",2)  
  add(pall[3][11],5,2)
 elseif chat==1 and nb==3 then
  pall[1038][4][2]=6
 elseif chat==1 and nb==7 then
  st_coffee=true
 elseif st_coffee and chat==1 and nb==8 then
  aall[2][3][1]="in fact... yes."
  pall[2][3][1]=4
  return 1,9
 elseif chat==1038 and nb==8 then
  aall[1][1][1]="here is your coffee."
  pall[1][1][1]=7
 elseif not st_know_wbook and chat==1011 then
  st_know_wbook=true
 elseif not st_camera and chat==5 and nb==8 then
  st_camera=true
  add(aall[1][1],"can i photograph you?")
  add(pall[1][1],8)
 elseif chat==2 and nb==100 then
  del(npc,amelia)
  return 1006,1
 elseif st_key_g and chat==1025 then
  mset(60,5,229)
  del(npc,door_g)
  return 1031,1
 elseif not st_key_l and chat==1005 then
  st_key_l=true
  del(npc,key_l)
 elseif not st_key_g and chat==1004 then
  st_key_g=true
  del(npc,key_g)
 elseif st_key_g and chat==1025 then
  mset(60,5,229)
  del(npc,door_g)
  return 1031,1
 elseif st_key_g and chat==1032 then
  mset(49,3,175)
  del(npc,door_g2)
  return 1031,1
 elseif st_key_l and chat==1033 then
  mset(8,13,229)
  del(npc,door_l)
  return 1034,1
 elseif chat==905 and nb==2 then
  del(npc,flag_l)
  mset(8,15,184)
 elseif not st_letter and chat==1012 and nb==2 then
  del(npc,letter)
  st_letter=true
  add(aall[1][1],"i found a strange letter\
from gRUMMAN",3)
  add(pall[1][1],6,3)
 elseif st_know_wbook and chat==1022 then
  add(aall[5][2],"i found your grey book!",6)
  add(pall[5][2],7,6)
  del(npc,wbook)
  return 1003,1
 elseif not st_crowbar and chat==1035 then
  st_crowbar=true
  del(npc,crowbar)
 elseif st_crowbar and chat==1036 and nb==1 then
  f1.nbspr=205
  f2.nbspr=205
  f3.nbspr=205
  return 1037,1
 elseif st_crowbar and chat==1037 and nb==2 then
  mode=4
  music(53)
  t0=t()
 end
end
-->8
-- title screen

title_screen={
{x=29,y=27,dx=0,dy=-1},
{x=29,y=18,dx=-1,dy=0},
{x=12,y=18,dx=0,dy=-1},
{x=12,y=8,dx=1,dy=0},
{x=18,y=8,dx=1,dy=0},
{x=35,y=8,dx=0,dy=1},
{x=35,y=19,dx=1,dy=0},
{x=42,y=19,dx=0,dy=-1},
{x=42,y=12,dx=1,dy=0},
{x=58,y=12,dx=0,dy=-1},
{x=58,y=4,dx=-1,dy=0},
{x=43,y=4,dx=0,dy=1},
{x=43,y=18,dx=-1,dy=0}}
title_index=1

function update_title()
 local s=title_screen[title_index]
 
 local i2=
 (title_index==#title_screen)
  and 2
  or title_index+1
 n=title_screen[i2]
 camx+=s.dx/2
 camy+=s.dy/2
 if camx==n.x*8-60 and camy==n.y*8-60 then
  title_index=i2
 end

 if mode==3 and btnp(🅾️) then
  music(22)
  mode=1
  p={x=29*8,y=(22+5)*8,o=0,f=false}
  p.ox=p.x
  p.oy=p.y-5*8
  camx=p.x-60
  camy=p.y-68
  start_dial(900)
 end
end
-->8
-- circle

function update_circle()
	if mode==4 then
	 local centerx=43*8
	 local centery=13*8
	 local rad=30
	 local dt=t()-t0
	 local m=t4-t3
	 if dt<t2 then
 	 camx=centerx-64
 	 camy=centery-64
	 elseif dt<t3 then
	  local c=rad*(dt-t2)/(t3-t2)
 	 camx=centerx-64+c*cos(.05)
 	 camy=centery-64+c*sin(.05)
 	elseif dt<t4 then
 	 camx=centerx-64+rad*cos(.05+((dt-t3)%m)/m)
 	 camy=centery-64+rad*sin(.05+((dt-t3)%m)/m)
	 elseif dt<t5 then
	  local c=rad*(1-(dt-t4)/(t5-t4))
 	 camx=centerx-64+c*cos(.05)
 	 camy=centery-64+c*sin(.05)
 	elseif dt>t6 then
 	 mode=5
 	 t0=t()
 	end
 end	
end

pts={{x=49*8+2,y=6*8+7},
 {x=36*8+7,y=6*8+7},
 {x=34*8+4,y=14*8+4},
 {x=43*8+4,y=21*8+6},
 {x=51*8+4,y=14*8+4},
 {x=49*8+2,y=6*8+7}}

function draw_circle(doall)
 local centerx=43*8
 local centery=13*8
 local rad=70
 local dt=t()-t0
 if(doall) dt=100
 
 if dt>t11 then
  local r=min(10,(dt-t11)/(t1-t11)*10)
  for i=-1,1 do
   for j=1,5 do
    circ(pts[j].x,pts[j].y,r+i,2)
   end
  end
  for j=1,5 do
   circ(pts[j].x,pts[j].y,r,8)
  end
 end
 
 if dt>t1 then
  for i=-1,1 do
	  circ(centerx,centery,rad+i,2)
	 end
	 circ(centerx,centery,rad,8)
	end
	
	if dt>t3 then
  local m=t4-t3
	 local nb=min(6,5*((dt-t3)/m)+1)
	 for k=-1,1 do
		 for j=-1,1 do
 		 line()
 	  for i=1,nb do
 		  line(pts[i].x+j,pts[i].y+k,2)
 		 end
		 end
	 end
	 line()
	 for i=1,nb do
 	 line(pts[i].x,pts[i].y,8)
 	end
 end
 if dt>t5 then
   for i=-1,1 do
	  circ(centerx+2,centery+2,50+i,2)
	 end
	 circ(centerx+2,centery+2,50,8)
	end
end

fire={{x=40,y=20,t=9*rnd()},
{x=46,y=13,t=9*rnd()},
{x=40,y=14,t=9*rnd()},
{x=42,y=19,t=9*rnd()},
{x=38,y=21,t=9*rnd()},
{x=44,y=22,t=9*rnd()},
{x=36,y=20,t=9*rnd()},
{x=41,y=22,t=9*rnd()},
{x=38,y=15,t=9*rnd()},
{x=40,y=17,t=9*rnd()},
{x=50,y=14,t=9*rnd()},
{x=41,y=10,t=9*rnd()},
{x=46,y=10,t=9*rnd()}}

expl={}
for i=1,3 do
 add(expl,{x=8*36+rnd(8*16),y=10*8+rnd(8*13),r=rnd(8)})
end

function draw_fire()
 for f in all(fire) do
  spr(185+(f.t+10*t())%4,f.x*8,f.y*8-2)
 end
 for f in all(fire) do
  spr(201+(f.t+10*t())%4,f.x*8,f.y*8-8-2)
 end
 spr(189,grey.x*8,grey.y*8-13+2*cos(2*t()))
 grey.f=t()%.5<.25
 for e in all(expl) do
  circfill(e.x,e.y,e.r,8)
  circfill(e.x,e.y,e.r-ceil(e.r/3),9)
  e.r+=.2
  if e.r>9 then
   e.x=8*36+rnd(8*16)
   e.y=10*8+rnd(8*13)
   e.r=0
  end
 end
end
__gfx__
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000eeeeeeeeee1111eeeeeeeeeeeeeeeeeeeeee77eeee11111eee9eeeeeeeeeeeeeee9eeeeeeeeeeeeeeeeeee9eeeeeeeeeeeeeee9eeeeeeee9eeeeeeee
00000000ee0000eeee111111ee0000eeeeeeeeeeeee7777e1111111eeee999eeee9eeeeeeee999eeee9eeeeeee9999e9eeeeee9eee9999e9eeeeee9eeeeeeeee
00000000e000000eeaaaaaaeee00ffeeeeffffeee7e77ffeeaaaaaaeee99999eeee999eeee99999eeee999eee99999eeee9999e9e99999eeee9999eeeeee77ee
00000000e0000feeeaaaafeaee0fffeeeeffffee7777fffeaeaaaaaeee99999eee99999eee99999eee99999ee9999feee99999eee9999feee99999eeeee7777e
00000000e000ffeeeaaaffeeeeffffeeeeffffee777ffffeeeaaaaaeee99999eee99999eee99999eee99999ee999ffeee9999feee999ffeee9999feee7e77ffe
00000000eeffffeeaeafffeee49494eeeeffffeee79fffeeeefaaafeee99999eee99999eee99999eee99999ee999ffeee999ffeee999ffeee999ffee7777fffe
00000000eefffeeeeefffeeee92222eeeefffeeeee4666eceeefffeeee99999eee99999eee99999eee99999ee999feeee999ffeee999feeee999ffee777ffffe
00000000ee1111eeeeddddeee42222eeee77c7eeee466ffceedddddeee19991eee99999eee19991eee99999eee9111eee999feeeee9111eee999feeee7efffee
00000000ee1111eeeeddddeeee22f2eeee7ccceeee4666deeedddddeee11111eee19991eee11111eee19991eee1111eeee9111eeee1111eeee9111eeeee666ee
00000000ee1171eeeeddfdeeee2222eeeeccfceeee4444eeeedddddeee11111eee11111eee11111eee11111eee11f1eeee1f11eeee11f1eeee111feeeee66fee
00000000ee1111eeeeddddeeee2222eeeecccceeee4e24eeeedddddeee11111eee11111eee11111eee11111eee1111eeee1111eeee1111eeee1111eeeee666ee
00000000eee442eeeee442eeeeedd1eeeeedd1eeee4ee4eeee22e44eee22e44eeeeee44eee22e44eee22eeeeeee442eeee44e22eeee244eeee22e44eeeeed1ee
655555556555555577777777777777777777777770000000e5666665000000077000000777777777777777777777777751551115565565562525252551111111
56555555565555556666666664444466dddddddd70000000e5664665000000077000000770000000000000000000000711555511556555652555555515111111
55655555556555556666666664111466dddddddd70000000e5555555000000077000000770000000000000000000000715555555555656552555555511511111
55565555555655556666666664111466dddddddd70000000eeeeeeee000000077000000770000000000000000000000715555555555565552555555511151111
55656555556565556666666664444466dddddddd70000000eeeeeeee000000077000000770000000000000000000000755555551555655555252525211515111
56555655524242456666666662444466dddddddd70000000eeeeeeee000000077000000770000000000000000000000755555551556565555555255515111511
65555565642424256666666664444466dddddddd70000000eeeeeeee000000077000000770000000000000000000000711555511565556555555255551111151
5555555652424246ddddddddd44444dd1111111170000000eeeeeeee000000077000000770000000000000000000000751115515655655655555255511111115
444444444444444444444444111111111111111111111111ebb7bbbeeeeeeeeeeeee3b3e6000000066166166565565561d11ddd19eeee88888eeee9e66666666
4444444444dddd44444444441dddddddddddddd11dddddd1e377373eeeeeeeeee33eb4b360000000671111773b355565dd1111dde9e88ee9ee88e9ee6a666666
4444444444111144444444441dddddddddddddd11dddddd1e337337eeeeeeeee3b3333436000000017176171b3b65655d1111111ee8eee9e9eee8eee66363666
499999994911119999999994111111111111111111111111e777737eeeeeeeeeb43b334360000000151561513b356555d1111111e8eeee9e9eeee8ee66636666
1eeeeeee1e1111eeee1dddd1100223300110440110044221e377737ee949949e3b43b43e6000000011111111b3b655551111111de8e8e8e8e8e8e8ee66635666
1eeeeeee1e1111eeee1d11d110088bb00cc0990110099881e777773ee994499ee33434be60000000161771613b3565551242424d8e8e9eeeee9e8e8e66656666
1eeeeeee1e1ee1eeee1dddd110088bb00cc0990110099881e337373ee949949eee334b336000000016177161b3b55655d424242d8e8e9eeeee9e8e8e66666666
1eeeeeee1e1ee1eeee111111111111111111111111111111ee3373eee424424ee3b3433e600000001111111165565565124242418ee8eeeeeee8ee8e66666666
eeeeeeeeeeeeeeeeeeeeeeee100110440022110110330441eeeeeeeee442244eee343eee666666666666666666666666666666668e9e8eeeee8e9e8e66656666
e1111111e11111111111111e100cc0990088cc0110bb0991e949949e9442244eeee4eeee666666666555555667776777666666668e9e8eeeee8e9e8e69999966
e15331c1e17cc1cc77ccc71e100cc0990088cc0110bb0991e994499e9424424eeea49eee66666666665666666777677766666636e8e9e8e9e8e9e8ee64444466
e15541c1e1ccc1c77ccc7c1e111111111111111111111111e949949e949949eeea9499ee66666666665666666555655566636366e8eeee8e8eeee8ee64444466
e1bbb171e1ccc177ccc7cc1e102204400220033112211331e424424e424424eee49994ee66666666555555556666666666663666ee8eee8e8eee8eee66656666
e1111111e11111111111111e1088099008800bb1188ccbb1e442244e442244eee44444ee66666666666665666667776666553566e9e88ee8ee88e9ee66656366
eeeeeeeeeeeeeeeeeeeeeeee1088099008800bb1188ccbb1e442244e442244eee24442ee666666666666656666677766666656669eeee88888eeee9e66653666
eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111e424424e424424eeee222eee66666666665555566665556666666666eeeeeeeeeeeeeeee66666666
eeeee77777eeeeeeeeeeeeeeeeeeee7777777eeeeeeeeeeeeeeeeee77777eeeeeeeeeeeeeeeeeee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeee7000007eeeeeeee8ee8eeeeee711111117eeeeeeeeeeeeeeee7000007eeeeeeeeeeeeeeeee0ffffff0eeeeeeeeeeeeeeeee000000eeeeeeeeeeeeeeee33e
eee700000007eeeeee89aeeeeeeee711111117eeeeeeeeeeeeeee7000fff07eeeeeeeeeeeeeee0fff6ff6f0eeeeeeeeeeeeeee07777770eeeeeeeeeeeb3e33b3
ee70000000007eeeeee898eeeeee71111111117777eeeeeeeeeee700fffff07eeeeeeeeeeeeee0666466460eeeeeeeeeeee000777777770eeeeeeeeeb433b34b
e70000000f0007ee8ee8a98eeeee711111111111117eeeeeeeee700ff1ff1f7eeeeeeeeeeeeee06ff6ff6f0eeeeeeeeeee0770777ff7ff0eeeeeeeeee34b34b3
e700000ffff0007eee89a8eeeeee7aaaaaaaaa7777eeeeeeeeee700fffffff7eeeeeeeeeeeeee0ffffffff0eeeeeeeeee0777777ffffff0eeeeeeeeeeb43433e
700000f1ff1f07eee89a8eeeeeee7a9aaafffaa7eeeeeeeeeeee70fff5ffff7eeeeeeeeeeeeee0ffffffff0eeeeeeeeee077777fffcffc0eeeeeeeee33b433ee
e77000ffffff7eeee8a8eeeeeeee7aa9ffafffa77777777eeeeee7ffff55f7e777777eeeeeeeee0ffff55f0eeeeeeeeee07777ffffffff0eeeeeeeeee3343b3e
ee700fffffff7eeeee8eeeeeeeee7aaffcafcf7a66666667eeeeee77ffff7e71c11c17eeeeeeeee06ffff0eeeeeeeeeeee07777ff5fff00eeee0eeeeeee343ee
e7077fff55f7eeeeee7eeeeeeeee7aafffffff7767888767eeeee74449944771c11c17eeeeeeeee066ff60eeeeeeeeeeeee0777eff550eeeee010eeeeeee4eee
ee77666fff7eeeeeee77eeeeeee7aafff5ffff7767787767eeee799444994441c11c17eeeeeee00c76776100eeeeeeeeee0999555ff0eeeee0110eeeeeea49ee
ee7611606667eeee7e777eeeeeee7a7fff55f7e766666667eee799994499445655657eeeeeee0777c77771c70eeeeeeee09045666555500001110eeeeea9499e
e70aaa6161167eee777877eeeeeee7e7ffff7eee77ffff7eee7449994449945655657eeeeee0777ccc771cc770eeeeee0400455666660111111ffeeeee49994e
70a101a111110770778787eeeeee77777ff7777ee7ffff7eee7444222200225655657eeeeee0777ccc771ccc770eeeee04045665666601d1111ffeeeee44444e
7011101a11111001077877eeeee71111ffff1117ee7ff7eeee799922209289889807eeeeee07777cccc1cccc7770eeee04045665556601d1d1110eeeee24442e
701111001111101107777eeeee71ddd1ffff1dd1777ff7eee74492220222898898207eeee077770cccc1dccc7770eeee04045666665fff1d111d0eeeeee222ee
7a011111001161111077eeeee71dddd11fff11dd117ff7eee70422220292898898207eeee077700cccc1cccc07770eee040405666665ff111110eeee65555555
7a00111111001611110eeeee71dddd1dd111dd1ddd1ff7ee70220222022223b33b3207eee077770cccc1dccc07770eee0404045555560dddd10eeeee56555555
e7a1001111111611660eeeee71ddd1dddd1dddd1dd1ff7ee70222002029223b33b3207eeee07777cccc1cccc07770eee040400566666600000eeeeee55655555
e70aaa0011111166eeeeeeee7f111dddddd1dddd11fff7ee70222220000223b33b32207eeee077fcccc1dccc0ff0eeee0400405665555566650eeeee55565555
e70111160011007eeeeeeeee7fff1dddddd1dccd1fff7eeee70022222220ffffff02207eeeee0ffc11c1c11ccff0eeeee040405666666666650eeeee55656555
e70111161100107eeeeeeeee7fff1d1dddd1dddd1777eeeeee7700022220ffffff02207eeeee0ffcccc1cccccf0eeeeee044445666666666650eeeee56555655
e70111161116107eeeeeeeee7fff1dd11d1ddd117eeeeeeeeeee70200002222fff7007eeeeeee0ccccc71cccc0eeeeeeee04444556666655650eeeee65555565
e70111161116107eeeeeeeeee7fff1dddd1dddd17eeeeeeeeeee70220222222077e77eeeeeeeee0ccc77722220eeeeeeee04444445666666550eeeee77777777
eeeeeeeeeeeeee77eeeeeeee1111111111111111eeeeeeee222222222222222222222222eeeedeeeeee343ee22222222eeeeeeeeeeee929eeeeeeeee33333333
eeeeeee7777777997eeeeeee1dddddddddddddd1eeeeeeee251cc2111512cc111211cc12eeeedeeeeeee4eee2333cc32eee65eeea2ae999eeeeeeeee33333b3b
eeeeee799999997797eeeeee1dddddddddddddd1e4eeeeee21cc12111152c111125cc112eeee1eeeeeee4eee233cc332ee6556eeaaae999eeeeeeeeeb3b33b3b
eeeee79999fff9977eeeeeee1111111111111111e3eee4ee2cc5121111c2111112cc1112eddd1eeeeee949ee23cc3332eeeeeeeeaaaee9eeeee8eeeeb3b33333
eeee79999ffff997eeeeeeee1003304400110221b33ee3ee2c5152111cc2511112c15112eddd1eeeee99499e2cc33232eeeeeeeeeae3e3eeeeee3eee33333333
eee7999993ff3f997eeeeeee100bb09900cc0881b33eb33e25111251cc121511c2111512e1111eeeeee999ee2c333332eeeeeeeee3ee33eeeee333ee3333b3b3
eee79999ffffff997eeeeeee100bb09900cc0881b33eb33e2111121cc112115cc2111152e10e1eeeeeeeeeee23333332eeeeeeeee3eee3eee239322e3333b3b3
eee79999ffffff997eeeeeee1111111111111111b33eb33e222222222222222222222222e1ee1eeeeeeeeeee22222222eeeeeeee222e222ee32323ee33333333
ee79999ff5ffff997eeeeeee10220440011033013334b3342222222222222222222222222222222233333332eeeeeeeeeeee3bee828eeeeee322233e33333333
ee79999fff55f9997eeeeeee108809900cc0bb0144443334233cc2333332cc333233cc323332cc3333333332ebbbeeeeb3e3beee888eeeeee32223e83b3b3333
ee799999ffff99997eeeeeee108809900cc0bb014444444423cc32333332cb3b323cc3323332c33333333332beeebeebeb34ee3b888e828e3e8223e33b3b3333
ee799999ff9999997eeeeeee1111111111111111999999942cc3323333c23b3b32cc333233c2333333333332b333bebbee34e3bee8ee888e3eee33e333333333
ee799999ff099997eeeeeeee1001133011044001eeeeeee12cb3b2333cc2333332c333323cc2333333333332bbbbbbbebee43beee3e3888e8ee3e3ee33333b3b
eee799990ff09997eeeeeeee100ccbb0cc099001eeeeeee123b3b233cc323333c2333332cc32333333333332bbbbbbeeeb343eeee33ee8eeee3ee8ee33333b3b
eeee7999100199907eeeeeee100ccbb0cc099001eeeeeee12333323cc332333cc2333332c332333c33333332bbbbbeeeeee4eeeee3eee3eeee38ee3eb3b33333
eee709911111091107eeeeee1111111111111111eeeeeee122222222222222222222222222222222333333323bbb3eeee22222ee222e222ee8eeee3eb3b33333
ee70111111061111107eeeee4444444444444444eeeeeeeeee444eeeeee444eeeeeeeeee4444444444444441eeee9eeee22222ee222e222ee322223e33333333
e7011111101161101107eeee4444444444444444e44444eeeee00eeeeee00eeeeeee44ee4444444444444441eeee9eeeee222eee222e222e3e22223e33333333
70111666011116660107eeee44444444444444444444444eee4aa4eeee4aa4eeeee00eee4444444444444441eeee4eeeee222eeeeeeeeeee3e2223e833333333
701111106111611601107eee4999999999999994e49994eee4a9994eee4a994eeee4a4ee4444444444444441e9994eeeeeeeeeeeeeeeeeee83eee3ee33333333
701111101616111610107eee4eeeeeeeeeeeeee4eee2eeee4a999994e4a9994eee4a994e4999999999999941e9994eeeeeeeeeeeeeeeeeeee3ee8e3e33333333
701101101161111610107eee4eeeeeeeeeeeeee4eee2eeee49999994e4999994e4a9994e4211151115111541e4444eeeeeeeeeeeeeeeeeeeee3eee3e33333333
701101101111111610107eee4eeeeeeeeeeeeee4ee222eeee4999994ee49994ee499994e4211115151111141e42e4eeeeeeeeeeeeeeeeeeee8e3e3e333333333
701101011111111610107eee4eeeeeeeeeeeeee4e2eee2eeee444422eee4422eee44422e4111111511111145e4ee4eeeeeeeeeeeeeeeeeeeeee3eee833333333
4444444444444444444444444444444444444444eeeeeeee911111191d11ddd151551115ee2ee28e2eeeee2e2eeee8ee2e2ee8eee9e9e9eeeeee282eeeeeeeee
4999999999999994499999944999999999999994ee66eeee49999994dd1111dd15335511e28eee82e8e2ee8e88e2ee2ee882ee28e9e9e9eee22e8482eeeee22e
4999999999999994499999944999999999999994e6eeeeee44999644d111111113373555e882ee88e88ee88ee88ee889e888e888e9e9e9ee28222242e82e2282
4444444444444444444444444444444444444444ee8eeeee29999962d111111117773335988ee88e888ee888e98ee89e998ee89eeeeeeeee8428224284228248
4002233001100004404402244003304400110224eee8eeee29fff9721111111d53777371e98e888899898988e98a8988e98a898ee9e9e9ee2842842ee2482482
40088bb00cc0000440990884400bb09900cc0884eeee8eee29fff9721111111d55337731ea98a988ea99a998ea99898ee8998988eeeeeeeee224248ee842422e
40088bb00cc0000440990884400bb09900cc0884eeeee6ee29666972dd1111dd1155335198999a98a8989a88e9889aeea9889a89eeeeeeeeee224822228422ee
4444444444444444444444444444444444444444eeeeeeee267777621ddd11d151115515eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee282422ee224282e
4001104400221104422113344022044001103304eeeeeeeeeeeeeeee0eeeeee0eeeeeeeeeeee5eeeeee55eeee500eeeeeeeeeeeeebb7bbbeee242eeeeee242ee
400cc0990088cc04488ccbb4408809900cc0bb04ea8aa8aee00000e080e00e080e00000eeee500eeee5000ee500eee0ee0ee5eeee377373eeee4eeeeeeee4eee
400cc0990088cc04488ccbb4408809900cc0bb04eaa88aae088888008808808800888880ee50000eee000ee0eeeeeee05ee005eee337337eeea49eeeeeee4eee
4444444444444444444444444444444444444444ea8aa8aee0888800888888880088880eeee500eee500ee0050eeeeeeeeee000ee97779aeea9499eeeee949ee
4022044002200334403301144001133011044004e989989eee08888088888888088880eeee5000ee500eeeee00e5eeeeeee500eee897a88ee49994eeee99499e
4088099008800bb440bb0cc4400ccbb0cc099004e998899eeee088880000000088880eeee50000eee50eeeeeee50eeeeee000eeeee888eeee44444eeeee999ee
4088099008800bb440bb0cc4400ccbb0cc099004e998899eeeee0088800880088800eeeeee500eeeeee5eeeeee000eeee50000eeeeeeeeeee24442eeeeeeeeee
4444444444444444444444444444444444444444e989989eeeeeee000088880000eeeeeeeee0eeeeee000eeee50000eeee000eeeeeeeeeeeee222eeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee9111111951111111eeeeeeeee088880eeeeeeeeeeee00eeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4999999415111111eeeeeeee00088000eeeeeeeeee0a90ee0a90eeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4466664411511111eeeeeee0888888880eeeeeeeee099900a99000ee00ee0000e0a90eee00eee00e00e00ee00eeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee2677776211151111eeeeee088888888880eeeeeee0a999009990a900a900a9990a999000a9000a90a90a900a90eeeeee
eeeeee9eeeeeeeeeeeeeee9eeeeeeeee2766667219494941ee00e08888088088880e00eee099990999909900990a9999099990a9999909999909900990eeeeee
eee999eeeeeeee9eeee999eeeeeeee9e2777777214949491e0880088800880088800880ee099099909909909900990000990009900990990000990990eeeeeee
ee99999eeee999eeee99999eeee999ee2766667259494941088888888888888888888880e099099009909909900999900990099999990990ee0990990eeeeeee
ee9fff9eee99999eee9fff9eee99999e2677776211111115088888888888888888888880e0990990099009090e0009990990099000000990eee09090eeeeeeee
ee9fff9eee9fff9eee9fff9eee9fff9e2777777277777777e0880088000880088800880e0990e000990e099900900099099900990090090eeee09990eeeeeeee
ee9fff9eee9fff9eee9fff9eee9fff9e2777777260000444ee0008888008808880e000ee0990eee0990e0990e0999990099900999990990eeee0990eeeeeeeee
ee99f99eee9fff9eee99f99eee9fff9e2777777260000414eeee0888800888880eeeeeeee00eeeee00e00990ee000000e0000000000e00eeee00990eeeeeeeee
ee91119eee99f99eee91119eee99f99e2777767260000414eeeee08800888880eeeeeeeeeeeeeeeeee09990eeeeeee0a00a9990eeeeeeeeee09990eeeeeeeeee
ee11111eee91119eee11111eee91119e2777767260000444eeeeee000888880eeeeeeeeeeeeeeeeeee0990eeeeeeee090090990eeeeeeeeee0990eeeeeeeeeee
eef111feeef11f1eeef111feee1f11fe9776677960000442eeeeeee0888880eeeeeeeeeeeeeeeee000e00eeeeeeee099099090eeeeeeeeeeee00eeee00eeeeee
ee11111eee22111eee11111eee11144e4999999460000444eeeeeee0880880eeeeeeeeeeeeeeee0a90eeeeeeeeeee099099090eeeeeee00eeeeeeee0a90eeeee
ee22e44eee22e44eee22e44eee22e44e44444444d0000444eeeeeee0880880eeeeeeeeeeeeeee0a990ee00ee00e00e0000000ee0000e0a90e00e00e09900000e
eeeeeeeeee3b3b3eeeeeeeeee77e777e66666eeeeeeaeeeeee28889e088880eeeeeeeeeeeeeee0999000a900a90a90e00a900e0a9990a9990a90a900000a9990
eeeeeeeee83b3b3eeeeeeeeee776777e76867eeeaaa9aeeee28889000888880eeeeeeeeeeeee0990990099999999990a999990a9999099990999990a90a99990
e55ee77ee8eeeeeeeeeeeeeee77666ee77777eeea9eaeeeeee288890e0088880eeeeeeeeeeee099099009900990099099009909900009900099000099099000e
e577e77eee8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee088080ee66666eeee099009900990099009099999990999900990e0990ee099099990e
e577e77eeeeeeeeeeeeee55eeeeeeeeeeeeeeeeeeeeeeeeee28889e0e0888880ee66666eeee099999909900990099099000000009990990e0990ee0990009990
ee77eeeeeeeeeeeeeeeee66eeeeeeeeeeeeeeeeeeeeeeeee2888900ee088880ee6555556ee09900099099009900990099009090009909990090eee0909000990
eeeeeeeeeeeeeeeeeeeee66eeeeeeeeeeeeeeeeeeeeeeeeee28889eeee0880eee6577756ee0990e099999009900990099999099999009990990ee0990999990e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeee5667665eee00eee00000ee00ee00ee00000e00000ee000e00eeee00e00000ee
__label__
00000000000000000000000000000000000000000000000000000755656555556565555565655555656555556565555565655555656555556565555565655555
00000000000000000000000000000000000000000000000000000756555655565556555655565556555655565556555655565556555655565556555655565556
00000000000000000000000000000000000000000000000000000765555565655555656555556565555565655555656555556565555565655555656555556565
00000000000000000000000000000000000000000000000000000755555556555555565555555655555556555555565555555655555556555555565555555655
00000000000000000000000000000000000000000000000000000077777777777777777777777777777777777777777777777777777777777777777777777777
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000008000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888880088088088008888800000
00000088220000000088220000000000000000000000000000000000000000000000000000000000000000000000000000000088880088888888008888000000
00000088220000000088220000000000000000000000000000000000000000000000000000000000000000000000000000000008888088888888088880000000
00000088222200008822220000000000000000000000000000008888000000000000000000000000000000000000000000000000888800000000888800000000
00000088222200008822220000000000000000000000000000008888000000000000000000000000000000000000000000000000008880088008880000000000
00008822222200008822220088880000888800008888222200882222220000008888000000888800888800888800008888000000000000888800000000000000
00008822222200008822220088880000888800008888222200882222220000008888000000888800888800888800008888000000000000888800000000000000
00002222222200222222220022220000222200882222222200882222220088882222222200222222222200222200002222000000000000088000000000000000
00002222222200222222220022220000222200882222222200882222220088882222222200222222222200222200002222000000000088888888000000000000
b7002222002222220022220022220022220000222200000000222200000022220000222200222200000000222200222200111111110888888888800000000000
77002222002222220022220022220022220000222200000000222200000022220000222200222200000000222200222200dddd00d08888088088880000000000
37002222002222000022220022220022220000222222220000222200002222222222222200222200dddd00222200222200ddd088008880088008880088000000
77002222002222000022220022220022220000222222220000222200002222222222222200222200111100222200222200110888888888888888888888800000
77002222002222002222000000220022000200000022222200222200002222000000000000222200022330002200220002230888888888888888888888800000
77002222002222002222000000220022000800000022222200222200002222000000000000222200088bb00022002200088bb088008800088008880088000000
002222000b0000002222001000222222000022000000222200222222000022220000220000220010088bb00022222200088bb000088880088088800000000000
00222200110000002222001100222222000022000000222200222222000022220000220000220011111111002222220011111111088880088888000000000000
00222200011044002222001000222200000022222222220000222222000022222222220022220010011044002222001022044000008800888880000000000000
002222000cc0990022220010002222000000222222222200002222220000222222222200222200100cc099002222001088099000000008888800000000000000
550000100cc09900000001000022220000bb000000000000880000000000000000000000000001100cc00000222200108809900000b088888000000000000000
55000011111111110000110000222200111100000000000011000000000000000000001100001111111100002222001111111111111088088000000000000000
55555110220440110440002222220011044001102204008800008888222200102204400022033110220022222200311001133011044088088000000000000000
55555110880990cc09900022222200cc0990011088090088000088882222001088099000880bb110880022222200b1100ccbb0cc099088888000000000000000
55551110880990cc099000222200b0cc0990011088090022000022002222001088099000880bb11088002222000bb1100ccbb0cc099008888800000000000000
11551511111111111111002222001111111111111111002200002200222200111111111111111111110022220011111111111111111110088880000000000000
55111551551115000011150000111551551115515500222200222200220015515511155155111551551100005511150000111551551115088080000000000000
55551111555511000055110000551111555511115500222200222200220011115555111155551111555500005555110000551111555510888880000000000000
55555515555500888800551555555515555555155500222200222200220055155555551555000015555555155555008822005515555550888800000000000000
55555515555500888800551555555515555555155500222200222200220055155555551555000015555555155555008822005515555555088000000000000000
55555155550088222200515500005155000051000055000055000000005551000000005500888800550000550000002222005100000000700000000000000000
55555155550088222200515500005155000051000055000055000000005551000000005500888800550000550000002222005100000000700000000000000000
55551111550022222200110088880000888800888800110000888800005500888888220088222222008888008888000000550088888822000000000000000000
11551551110022222200150088880000888800888800150000888800005500888888220088222222008888008888000000550088888822000000000000000000
55111511002222002222000022222222222222222222008888222222220088222222220022222222002222222222888800008822222222000000000000000000
5555111d002222002222000022222222222222222222008888222222220088222222220022222222002222222222888800008822222222000000000000000000
5555551d002222002222000022220000222200002222002222000022220022220000000022220000002222000000222200002222000000700000000000000000
55555511002222002222000022220000222200002222002222000022220022220000000022220000002222000000222200002222000000700000000000000000
55555100222200002222000022220000222200002200222222222222220022222222000022220053002222005500222200002222222200700000000000000000
5555510022220000222200002222000022220000220022222222222222002222222200002222005b002222005500222200002222222200700000000000000000
55551100222222222222000022220000220000222200222200000000000000002222220022220033002222005500222200000000222222000000000000000000
11551500222222222222000022220000220000222200222200000000000000002222220022220053002222001100222200000000222222000000000000000000
55110022220000002222000022000022220000222200002222000022002200000022220022222200002200477400220000220000002222007777777bb7bbb777
5555002222000000222200002200002222000022220000222200002200220000002222002222220000220047760022000022000000222200ddddddd377373ddd
55550022220090002222002222000022220000222200002222222222002222222222000022222200222200470022220000222222222200d55dd77dd337337ddd
55550022220011002222002222000022220000222200002222222222002222222222000022222200222200490022220000222222222200d577d77dd777737ddd
55555100001330110000010000044000004001000004400000000000550000000000315500000054000051455500005555000000000051d577d77dd377737ddd
5555510000cbb0cc0000010000099000009001000009900000000000550000000000b15500000054000051455500005555000000000051dd77ddddd777773ddd
555511100ccbb0cc09900110880990cc0990011088099000880bb111555511188ccbb11155551112444211415555111155551411555511ddddddddd337373ddd
11551511111111111111111111111111111111111111111111111151115515111111115111551551222515411155155111551451115515111111111133731111
55111551551115515511155155111551551115515511155155111551551115515511155155111551551115515511155155111551551115515511155155111551
55551111555511115555111155551111555511115555111155551111555511115555111155551111555511115555111155551111555511115555111155551111
55555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515
55555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515
55555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155
55555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155
55551111555511115555111155551111555511115555111155551111555511115555111155551111555511115555111155551111555511115555111155551111
11551551115515511155155111551551115515511155155111551551115515511155155111551551115515511155155111551551115515511155155111551551
55111511111111111111111111111111111111111111111111111151551115111111111111111111111111111111111111111111111111777777777777777777
5555111dddddddddddddd11dddddddddddddd11dddddddddddddd1115555111dddddddddddddd11dddddddddddddd11dddddddddddddd1700000000000000000
5555551dddddddddddddd11dddddddddddddd11dddddddddddddd1155555551dddddddddddddd11dddddddddddddd11dddddddddddddd1700000000000000000
55555511111111111111111111111111111111111111111111111115555555111111111111111111111111111111111111111111111111700000000000000000
55555110022330001102211003304401104401100330440011022155555551100223300011022110033044011044011002233001104401700000000000000000
55555110088bb000cc0881100bb0990cc09901100bb09900cc08815555555110088bb000cc0881100bb0990cc0990110088bb00cc09901700000000000000000
55551110088bb000cc0881100bb0990cc09901100bb09900cc08811155551110088bb000cc0881100bb0990cc0990110088bb00cc09901700000000000000000
11551511111111111111111111111111111111111111111111111151115515111111111111111111111111111111111111111111111111700000000000000000
55111510011044000033011022044000221101100110440000330151551115100110440022110110220440002211011001104400221101700000000000000000
555511100cc0990000bb01108809900088cc01100cc0990000bb0111555511100cc0990088cc01108809900088cc01100cc0990088cc01700000000000000000
555555100cc0990000bb01108809900088cc01100cc0990000bb0115555555100cc0990088cc01108809900088cc01100cc0990088cc01700000000000000000
55555511111111111111111111111111111111111111111111111115555555111111111111111111111111111111111111111111111111700000000000000000
55555110220440110440011001133000220331102204401104400155555551102204400022033110011330002203311022044000220331700000000000000000
55555110880990cc099001100ccbb000880bb110880990cc099001555555511088099000880bb1100ccbb000880bb11088099000880bb1700000000000000000
55551110880990cc099001100ccbb000880bb110880990cc099001115555111088099000880bb1100ccbb000880bb11088099000880bb1700000000000000000
11551511111111111111111111111111111111111111111111111151115515111111111111111111111111111111111111111111111111700000000000000000
55111551551115515511155155111551551115515511155155111551551115515511155155111551551115515511155155111551551115700000000000000000
55551111555511115555111155551111555511115555111155551111555511115555111155551111555511115555111155551111555511700000000000000000
55555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555700000000000000000
55555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555700000000000000000
55555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551700000000000000000
55555155555551555550000000000000000000005550000055500000000051500000000000000000000000000000000000000000000051700000000000000000
55551111555511115550888088808880088008805550888055508880088011108880880080808880088088808880088088808880888011700000000000000000
11551551115515511150808080808000800080001150008011500800808015500800808080808000800008000800800080800800800015700000000000000000
55111551551115515510888088008800888088801110080011110800808015110800808080808800888008010800800088800800880111700000000000000000
5555111155551111555080008080800000800080ddd08000dddd08008080111008008080888080000080080008008080808008008000d1700000000000000000
5555551555775515555080108080888088008800ddd08880dddd08008800551088808080080088808800080088808880808008008880d1700000000000000000
55555515577775155550001000000000000000011110000011110000000555100000000000000000000100000000000000000000000011700000000000000000
55555157577ff1555555515555555110044221100223300110440155555551100330440110440110022330001102211003304400110221700000000000000000
5555517777fff155555551555555511009988110088bb00cc0990155555551100bb0990cc0990110088bb000cc0881100bb09900cc0881700000000000000000
555511777ffff111555511115555111009988110088bb00cc0990111555511100bb0990cc0990110088bb000cc0881100bb09900cc0881700000000000000000
115515574fff15511155155111551511111111111111111111111151115515111111111111111111111111111111111111111111111111700000000000000000
5511155146661c515511155155911510330441102204400000330151551115102204400022110110011044002211011022044000221101700000000000000000
55551111466ffc144444111155451110bb0991108809900000bb0111555511108809900088cc01100cc0990088cc01108809900088cc01700000000000000000
555555154666d5444444451555455510bb0991108809900000bb0115555555108809900088cc01100cc0990088cc01108809900088cc01700000000000000000
55555515444455149994551555455511111111111111111111111115555555111111111111111111111111111111111111111111111111700000000000000000
55555155452451555255515999455112211331100113301104400155555551100113300022033110220440002203311001133000220331700000000000000000
555551554554515552555154444551188ccbb1100ccbb0cc09900155555551100ccbb000880bb11088099000880bb1100ccbb000880bb1700000000000000000
555511115555111122251114254511188ccbb1100ccbb0cc09900111555511100ccbb000880bb11088099000880bb1100ccbb000880bb1700000000000000000
11551551115515521152155411451511111111111111111111111151115515111111111111111111111111111111111111111111111111700000000000000000
55111551551115515511155155111551551115515511155155111551551115515511155155111551551115515511155155111551551115700000000000000000
55551111555511115555111155551111555511115555111155551111555511115555111155551111555511115555111155551111555511700000000000000000
55555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555700000000000000000
55555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555700000000000000000
55555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551700000000000000000
55555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551700000000000000000
55551111555511115555111155551111555511115555111155551111555511115555111155551111555511115555111155551111555511700000000000000000
11551551115515511155155111551551115515511155155111551551115515511155155111551551115515511155155111551551115515700000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000220222022200220220000000000000022202220222022200000000000000000000000000000000000000000
00000000000000000000000000000000000000002000202002002020202000000000000000202020002020200000000000000000000000000000000000000000
00000000000000000000000000000000000000002000222002002020202000002220000022202020222020200000000000000000000000000000000000000000
00000000000000000000000000000000000000002000200002002020202000000000000020002020200020200000000000000000000000000000000000000000
00000000000000000000000000000000000000000220200022202200222000000000000022202220222022200000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000001000000000000000000000000000000010100000000000000000000010101010000000000000001010100010100000100000000000000000001010101000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001
0000000000000000000000000001010100000000000000000000010001010001000000000000000000000000000000010000000000000001010000000000010100000000000000000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000027222222222222222222222222222222222222222222222222222222250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000272283842222222222222222223525000000000000000027afaf9fafafafaf9fafaf8fafaf9fafafaf8fafaf9fafaf8fafafaf250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000002720934420202020202020202045250000000000000000278fafafaf9a9699999999988b96999799979998292a2a2a2a2a2b9f250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000272020202020202020202020202025000000000000000027afafaf8f9a2f2f2f2f2f2f2f2f2f2f2f2f2f2f25000000000027af250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000002720202020202020202020202020250000000000000000279fafafaf9a2f2f2f2f2f2f2fa9aaa9aa2f2f2f22222223b22527af250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000272020202020202020202020202025002722222222222228afafafaf9a2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fc22527af250000000000000000000000000000000000000000000000002722b0b1b3b4b0b4250000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000272020202020202020202020202025002720202020202028afaf9faf9a2f2f2f2f2f2f2fa9aaa9aaa9aa2f2f2f2f2f2f25279f2500000000000000000000000000000000000000000000000027b7c3c4c3c1c0c4250000000000000000000000000000000027222222222225000000000000
00000000000000000000000000002720202020202020202020202020222222202020202020252baf292a2b2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fa9aa2f2f2527af2500000000000000000000000000000000000000000000000027b7b7b7b7b7b7b72500000000000000000000000000000000272d2d2d2d2d25000000000000
0000000000000000000000000000272020202020202020202020202020202020202020202028244b2424248687878787878787882f86878787878787878824248f2500000000000000000000000000000000000000000000000027b0b1b7b7b7b3b12500000000000000000000000000000000103b2d2d2d2d25000000000000
00000000000000000000000000002720202020202020202020202020292a2b35202020338428494b494a49493f4949494a4949494b4f49494c4949494a494b4b4b2500000000000000000000000000000000000000000000000027c3c1b7b7b7c0c42500000000000000000000000000000000272d2d2d2d2d25000000000000
0000000000000000000000000000002a2a2a2a2a2a2a2a2a2a2b2029000027452020204394284b292a2a2a2a2a2a2a2a2b494c49494b4b49494a494b4b4b4949492500000000000000000000000000000000000000000000000027b7b7b7b7b7b7b72500000000000000000000000000000000002a2a2a2a2a00000000000000
000000000000000000000000000000000000000000000000002720250000277f7f7f7f7f7f284b28352424242424242424494b4b4b49494b4b4b4b49494949494c2500000000000000000000000000000000000000000000000027b7b7b73cb7b7b7250000000000000000000000000000000000000000000000000000000000
00278334338433842383843384833422333433843334250027242124242424242424242424244b28452e2e2e2e2e2e2e2e4b494a4949494a49292a2a2a2a2a2a2a00000000000000000000000000000000000000000000000000002a2a2a102a2a2a000000000000000000000000000000000000000000000000000000000000
00274344939443442c4394939443442c434443449394250027494b494949494a493f4b4b4b4b4c282e2e2e2e2e2e2e292b494949292a2a2a2a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00272c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2500273f4b49494c4949494b49494a4949282e2e2e2e2e2e2e25274a494925000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002733842c2c2c2c2c3384838433342c352c2c2c2c2c250027494b49494949494b49292a2a2a2a272e292a2a2a2a2a00002a2a2a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002743942c2c2c2c2c9394439443442c452c2c2c2c2c24242449494b4b49494b494a2500000000272e250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00272c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c4b4b49494b4b49494f2500002724242e242424242500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00273384333433842c3384833483842c338483343334292a2b4a493f494b494b4b49242424242e2e2e2e2e2e2e2500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00279394434493942c4394934443942c434493444344250027494949494b4949494b2e2e2e2e2e2e2e2e2e2e2e2500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00272c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c250027494c49494b49494949292a2a2b2e2e2e2e2e2e2e2500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00273334838433342c2c2c2c3533342c833433848384250027494949494b494c494a250000272e2e2e2e2e2e2e3900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00274394939443442c2c2c2c4593942c9344434493442500002a2a2b244b24292a2a000000002a2a2a2a2a2a2a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00272c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c250000000027494b492500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002722222222b3b1250000000000000000000000000000000000
00002a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a000000000027494b49250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000272f2f2f2fc3c4250000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000027494b49250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000272f2fd52f2f2f250000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000494b49000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a2a102b2fd4250000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000272fe4250000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a2a000000000000000000000000000000000000
__sfx__
011800200c0351004515055170550c0351004515055170550c0351004513055180550c0351004513055180550c0351104513055150550c0351104513055150550c0351104513055150550c035110451305515055
010c0020102451c0071c007102351c0071c007102251c007000001022510005000001021500000000001021013245000001320013235000001320013225000001320013225000001320013215000001320013215
003000202874028740287302872026740267301c7401c7301d7401d7401d7401d7401d7301d7301d7201d72023740237402373023720267402674026730267201c7401c7401c7401c7401c7301c7301c7201c720
0030002000040000400003000030020400203004040040300504005040050300503005020050200502005020070400704007030070300b0400b0400b0300b0300c0400c0400c0300c0300c0200c0200c0200c020
00180020176151761515615126150e6150c6150b6150c6151161514615126150d6150e61513615146150e615136151761517615156151461513615126150f6150e6150a615076150561504615026150161501615
00180020010630170000000010631f633000000000000000010630000000000000001f633000000000000000010630000000000010631f633000000000000000010630000001063000001f633000000000000000
001800200e0351003511035150350e0351003511035150350e0351003511035150350e0351003511035150350c0350e03510035130350c0350e03510035130350c0350e03510035130350c0350e0351003513035
011800101154300000000001054300000000000e55300000000000c553000000b5630956300003075730c00300000000000000000000000000000000000000000000000000000000000000000000000000000000
003000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01240020051450c145051450c145051450c145051450c145071450e145071450e145071450e145071450e1450d145141450d145141450d145141450d145141450c145071450c145071450c145071450c14507145
014800202174421740217402274024744247401f7441f7402074420740207401f7401d7401f7401c7441c7402174421740217402274024744247401c7441c7401d7441f740207402274024744247402474024745
012400200e145151450e145151450e145151450e145151450c145131450c145131450c145131450c145131450f145161450f145161450f145161450f145161450e145151450e145151450c145131450c14513145
011200200c1330960509613096131f6330960509615096150c1330960509613096130062309605096050e7130c1330960509613096131f6330960509615096150c1330960509613096130062309605096050e713
014800200c5240c5200c5200c52510524105201052010525115241152011520115251352413520135201352511524115201152011525135241352013520135251452414520145201452013520135201352013525
014800200573405730057300573507734077300773007735087340873008730087350c7340c7300c7300c73505734057300573005735077340773007730077350d7340d7300d7300d7350c7340c7300c7300c735
014800200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013200202005420050200502005520054200502005020055200542005020050200551e0541e0501c0541c05023054230502305023055210542105020054200501c0541c0501c0501c0501c0501c0501c0501c055
0132002025054250502505025055230542305021054210502805428050280502805527054270502305423050250542505025050250551e0541e0501e0501e0552305423050230502305023050230502305023055
0132002010140171401914014140101401714019140141400f14014140171401b1400f14014140171401b1400d1401014015140141400d1401014017140191400d1401014015140141400d140101401714019140
0132002015140191401c1401914015140191401c1401914014140191401b14017140121401414015140191401e1401914015140191401214014140151401914017140141401014012140171401e1401b14017140
013200202372423720237202372523724237202372023725237242372023720237252172421720207242072028724287202872028725257242572023724237202072420720207202072020720207202072020725
0132002028724287202872028725287242872028720287252c7242c7202c7202c7252a7242a72028724287202a7242a7202a7202a725257242572025720257252872428720287202872527724277202772027725
0019002001610016110161101611016110161104611076110b61112611166111b6112061128611306113561138611336112d6112961125611206111c6111861112611106110c6110861104611026110261101611
011e00200c505155351853517535135051553518535175350050015535185351a5350050515535185351a53500505155351c5351a53500505155351c5351a53500505155351a5351853500505155351a53518535
010f0020001630020000143002000f655002000020000163001630010000163002000f655001000010000163001630010000163002000f655002000010000163001630f65500163002000f655002000f60300163
013c002000000090750b0750c075090750c0750b0750b0050b0050c0750e075100750e0750c0750b0750000000000090750b0750c0750e0750c0751007510005000000e0751007511075100750c0751007510005
013c00200921409214092140921409214092140421404214022140221402214022140221402214042140421409214092140921409214092140921404214042140221402214022140221402214022140421404214
013c00200521405214052140521404214042140721407214092140921409214092140b2140b214072140721405214052140521405214042140421407214072140921409214092140921409214092140921409214
013c00202150624506285060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400181862500000000001862518625186251862500000186051862018625000001862500000000001862500000000001862518605186251862518605186250000000000000000000000000000000000000000
010f00200c0730000018605000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c073000000000000000
013c0020025500255004550055500455004550055500755005550055500755007550045500455000550005500255002550045500555004550045500555007550055500555007550095500a550095500755009550
013c00201a54526305155451a5451c545000001a5451c5451d5451c5451a545185451a5450000000000000001a5452100521545180051c5450000018545000001a545000001c545000001a545000000000000000
011e00200557005575025650000002565050050557005575025650000002565000000457004570045750000005570055750256500000025650000005570055750256500000025650000007570075700757500000
013c00200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013c00201d1151a1151a1151d1151a1151a1151c1201c1251d1151a1151a1151d1151a1151a1151f1201f1251d1151a1151a1151d1151a1151a1151c1201c1251d1151a1151a1151d1151a1151a1151f1201f125
011e0020091351500009135000050920515000091350000009145000000920500000071400714007145000000913500000091350000009205000000913500000091450000009205000000c2000c2050020000000
015000200706007060050600506003060030600506005060030600306005060050600206002060030600306007060070600506005060030600306005060050600306003060050600506007060070600706007060
01280020131251a1251f1251a12511125181251d125181250f125161251b125161250e125151251a125151250f125161251b1251612511125181251d125181250e125151251a125151251f1251a125131250e125
01280020227302273521730227301f7301f7301f7301f7352473024735227302273521730217351d7301d7351f7301f7352173022730217302173522730247302673026730267302673500000000000000000000
012800202773027735267302473524730247302473024735267302673524730267352273022730227302273524730247352273021735217302173021730217351f7301f7301f7301f7301f7301f7301f7301f735
015000200f0600f0600e0600e060070600706005060050600c0600c060060600606007060090600a0600e0650f0600f0600e0600e060070600706005060050600c0600a060090600206007060070600706007065
012800200f125161251b125161250e125151251a12515125131251a1251f1251a12511125181251d125181250f125161251b125161250e125151251a12515125131251a1251f1251a125131251a1251f1251a125
012800201a5201a525185201a525135101351013510135151b5201b5251a5201a525185201852515520155251652016525185201a52518520185251a5201b520155201552015520155251f5001f5001f5001f505
012800201f5201f5251d5201b525155101551015510155151d5201d5251b5201d5251a5101a5101a5101a5151b5201b5251a5201a52518520185201552015525165201652016520165251a5001a5001a5001a505
013c00201003500500000001003509000000000e0300e0351003500000000001003500000000000e0000e00511035000000000011035000000000010030100351103500000000001103500000000000400004005
011e00201813518505000001713517505000001513515505000001013010130101350000000000000000000015135000000000010135000000000011500115001150011500111301113011130111350000000000
01180020071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155051550c155081550c155051550c155081550c155051550c155081550c155051550c137081550c155
01180020071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1370c1550f155
01180020081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1370a1550e155
011800201305015050160501605016050160551305015050160501605016050160551605015050160501a05018050160501805018050180501805018050180550000000000000000000000000000000000000000
011800201305015050160501605016050160551305015050160501605016050160551605015050160501a0501b0501b0501b0501b0501b0501b0501b0501b0550000000000000000000000000000000000000000
011800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301a130181301613016130161301613016130161350000000000000000000000000000000000000000
011800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301d1301d1301d1301d1301d1301d1301d1301d1350000000000000000000000000000000000000000
01180020081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f1550a155111550e155111550a155111550e155111550a155111550e155111550a155111550e15511155
011800202271024710267102671026710267152271024710267102671026710267152671024710267102971027710267102471024710247102471024710247150000000000000000000000000000000000000000
01180020227102471026710267102671026715227102471026710267102671026715267102471026710297102b7102b7102b7102b7102b7102b7102b7102b7150000000000000000000000000000000000000000
011800202b720297202b7202b7202b7202b7252b720297202b7202b7202b7202b7252b720297202b7202e72029720277202672026720267202672026720267250000000000000000000000000000000000000000
011800202b720297202b7202b7202b7202b7252b720297202b7202b7202b7202b7252b720297202b7202e7202e7202e7202e7202e7202e7202e7202e7202e7250000000000000000000000000000000000000000
010c00200c133000000061500615176550000000615006150c133000000061500615176550000000615006150c133000000061500615176550000000615006150c13300000006150061517655000000061500615
0118002002070020700207002070040700407004070040700c0700c0700c0700c0700a0700a0700a0700a0700e0700e0700e0700e0700d0700d0700d0700d070100701007010070100700e0700e0700e0700e075
011800200000015540155401554015545115401154011540115451354013540135401354510540105401054010545115401154011540115451054010540105401054513540135401354013545095400954009545
0118002009070090700907009070070700707007070070700907009070090700907002070020700207002070030700307003070030700a0700a0700a0700a0700707007070070700707007070070700707007075
01180020000001054010540105401054511540115401154011545105401054010540105450e5400e5400e5400e545075400754007540075450e5400e5400e5400e54505540055400554005540055400554005545
__music__
01 08004243
00 08014300
00 03014300
00 02030500
00 02030500
00 03414300
00 08014500
00 03040500
00 03020500
00 03020500
02 08010706
01 0a4d0949
00 0a0d090c
00 0a4c0b4c
00 0a0d0e4e
02 0f4d0c09
01 10124316
00 11134316
00 10121416
00 11131516
00 12424316
02 13424316
01 19425b18
00 19175a18
00 19171a18
00 1b425c18
02 1a194318
01 1f1d5e60
00 1f1d5e20
00 1f1d4320
00 221d211e
00 231d211e
02 1c1d2444
01 25262744
00 292a2844
00 2526272b
02 292a282c
01 2d181e24
00 2d181e24
00 2d181e2e
00 2d181e2e
00 2d181e6e
02 2d181e6e
01 2f454305
00 30424305
00 2f324344
00 30334344
00 2f323705
00 30333805
00 31344344
00 36354344
00 31343905
02 36353a05
01 3c423b41
00 3c423b44
00 3c3d3b44
00 3c3d3b44
00 3e523b41
00 3e423b41
00 3e3f3b44
00 3e3f3b44
00 3e013b41
02 3e013b41

