from psychopy.visual.rect import Rect
from psychopy.visual.radial import RadialStim
from psychopy.visual.text import TextStim


class SlotMachine(object):
    def __init__(self, win, id='A', colour='blue', pos=[0, 0], size=0.2):
        # size is in height units
        self.colour = colour
        self.size = size
        self.arm = Rect(win, pos=(.5 * size + pos[0], pos[1]),
                        width=.6 * size, height=.1*size, fillColor=colour,
                        ori=-30)
        self.body = Rect(win, pos=pos, width=size,
                         height=size, fillColor=colour)
        self.ani = RadialStim(win, pos=pos, size=size * 0.8,
                              radialCycles=2, angularCycles=2)
        self.points = TextStim(win, text='Obtained\n0\npoints',
                               pos=pos, height=(size*.8)/6, alignHoriz='center',
                               alignVert='center', color='black')
        self.id = TextStim(win, text=id, pos=pos, height=size*.8, alignHoriz='center',
                           alignVert='center', color='black')
        self.fill = Rect(win, pos=pos, height=0.8*size,
                         width=0.8*size, fillColor='white')
        self._pts = False
        self._ani = False
        self._id = True

    def draw(self):
        self.arm.draw()
        self.body.draw()
        self.fill.draw()
        if self._id:
            self.id.draw()
        if self._ani:
            self.ani.ori += 2
            self.ani.draw()
        if self._pts:
            self.points.draw()

    def toggle_id(self, val):
        self._id = val

    def toggle_arm(self, val):
        self.arm.ori = val

    def toggle_ani(self, val):
        self._ani = val

    def toggle_points(self, val):
        self._pts = val

    def update_points_text(self, val):
        self.points.text = 'Obtained\n%i\npoints' % val
