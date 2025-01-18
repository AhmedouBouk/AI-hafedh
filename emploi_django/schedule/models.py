from django.db import models

# Create your models here.

class Course(models.Model):
    code = models.CharField(max_length=10, primary_key=True)  # e.g., IRT31
    title = models.CharField(max_length=100)
    credits = models.IntegerField()
    cm_hours = models.IntegerField()  # Planned CM hours
    td_hours = models.IntegerField()  # Planned TD hours
    tp_hours = models.IntegerField()  # Planned TP hours
    cm_completed = models.IntegerField(default=0)  # Completed CM hours
    td_completed = models.IntegerField(default=0)  # Completed TD hours
    tp_completed = models.IntegerField(default=0)  # Completed TP hours
    exam_sn = models.FloatField(null=True, blank=True)  # Exam SN (manually entered)
    exam_sr = models.FloatField(null=True, blank=True)  # Exam SR (manually entered)

    def __str__(self):
        return f"{self.code} - {self.title}"

    def progress_cm(self):
        return (self.cm_completed / self.cm_hours) * 100 if self.cm_hours > 0 else 0

    def progress_td(self):
        return (self.td_completed / self.td_hours) * 100 if self.td_hours > 0 else 0

    def progress_tp(self):
        return (self.tp_completed / self.tp_hours) * 100 if self.tp_hours > 0 else 0

    def total_progress(self):
        total_planned = self.cm_hours + self.td_hours + self.tp_hours
        total_completed = self.cm_completed + self.td_completed + self.tp_completed
        return (total_completed / total_planned) * 100 if total_planned > 0 else 0

class Professor(models.Model):
    name = models.CharField(max_length=100)
    courses = models.ManyToManyField(Course, through='CourseAssignment')

    def __str__(self):
        return self.name

class Room(models.Model):
    number = models.CharField(max_length=20)
    type = models.CharField(max_length=20)  # CM, TD, TP

    def __str__(self):
        return f"{self.number} ({self.type})"

class CourseAssignment(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE)
    professor = models.ForeignKey(Professor, on_delete=models.CASCADE)
    type = models.CharField(max_length=2, choices=[
        ('CM', 'Cours Magistral'),
        ('TD', 'Travaux Dirigés'),
        ('TP', 'Travaux Pratiques')
    ])
    room = models.ForeignKey(Room, on_delete=models.SET_NULL, null=True)

class TimeSlot(models.Model):
    DAYS = [
        ('LUN', 'Lundi'),
        ('MAR', 'Mardi'),
        ('MER', 'Mercredi'),
        ('JEU', 'Jeudi'),
        ('VEN', 'Vendredi')
    ]
    PERIODS = [
        ('P1', '08h00 à 09h30'),
        ('P2', '09h45 à 11h15'),
        ('P3', '11h30 à 13h00'),
        ('P4', '15h10 à 16h40'),
        ('P5', '16h50 à 18h20')
    ]
    
    day = models.CharField(max_length=3, choices=DAYS)
    period = models.CharField(max_length=2, choices=PERIODS)
    week = models.IntegerField()  # S1, S2, etc.
    course_assignment = models.ForeignKey(CourseAssignment, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('day', 'period', 'week')
