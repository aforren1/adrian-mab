from psychopy.visual.rect import Rect
from psychopy.visual.radial import RadialStim
from psychopy.visual.text import TextStim


class Feedback(object):
    def __init__(self, win, pos=[0, 0], size=0.25):
        self.body = Rect(win, pos=pos, width=size, height=size, fillColor='white',
                         lineColor='black')
        self.ani = RadialStim(win, pos=pos, size=size*0.8, radialCycles=2,
                              angularCycles=2)
        self.points_txt = TextStim(win, text='0',
                                   pos=pos, height=(size * .8)/2, alignHoriz='center',
                                   alignVert='center', color='black')
        self.points = 0
        self.state = 'idle'  # idle, ani, points, cooldown

    def draw(self):
        self.body.draw()
        if self.state == 'ani':
            self.ani.ori += 2
            self.ani.draw()
        elif self.state == 'points':
            self.points_txt.draw()

    @property
    def points(self):
        return self._points

    @points.setter
    def points(self, value):
        self._points = value
        self.points_txt.text = str(value)
