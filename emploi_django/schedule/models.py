from django.db import models

# Create your models here.

class Course(models.Model):
    code = models.CharField(max_length=10, primary_key=True)  # e.g., IRT31
    title = models.CharField(max_length=100)
    credits = models.IntegerField()
    cm_hours = models.IntegerField()  # Total planned CM hours
    td_hours = models.IntegerField()  # Total planned TD hours
    tp_hours = models.IntegerField()  # Total planned TP hours
    cm_completed = models.IntegerField(default=0)  # Will be calculated from schedule
    td_completed = models.IntegerField(default=0)  # Will be calculated from schedule
    tp_completed = models.IntegerField(default=0)  # Will be calculated from schedule
    exam_sn = models.FloatField(null=True, blank=True)
    exam_sr = models.FloatField(null=True, blank=True)

    def __str__(self):
        return f"{self.code} - {self.title}"

    def update_completed_hours(self):
        """Update completed hours based on scheduled sessions"""
        # Get all assignments for this course
        assignments = CourseAssignment.objects.filter(course=self)
        
        # Initialize counters
        self.cm_completed = 0
        self.td_completed = 0
        self.tp_completed = 0
        
        # Count scheduled sessions for each type
        for assignment in assignments:
            # Get all time slots for this assignment
            slots = TimeSlot.objects.filter(course_assignment=assignment)
            
            # Count slots by type
            if assignment.type == 'CM':
                self.cm_completed = slots.count() * 1.5  # Each slot is 1.5 hours
            elif assignment.type == 'TD':
                self.td_completed = slots.count() * 1.5
            elif assignment.type == 'TP':
                self.tp_completed = slots.count() * 1.5
        
        # Save the updated counts
        self.save()

    def get_planned_hours(self, type_code):
        """Get planned hours from schedule for a specific type"""
        assignments = CourseAssignment.objects.filter(course=self, type=type_code)
        total_slots = 0
        for assignment in assignments:
            total_slots += TimeSlot.objects.filter(course_assignment=assignment).count()
        return total_slots * 1.5  # Each slot is 1.5 hours

    def progress_cm(self):
        """Calculate CM progress percentage"""
        planned = self.get_planned_hours('CM')
        if planned <= 0:
            return 0.0
        return round((self.cm_completed / planned) * 100, 2) if planned > 0 else 0.0

    def progress_td(self):
        """Calculate TD progress percentage"""
        planned = self.get_planned_hours('TD')
        if planned <= 0:
            return 0.0
        return round((self.td_completed / planned) * 100, 2) if planned > 0 else 0.0

    def progress_tp(self):
        """Calculate TP progress percentage"""
        planned = self.get_planned_hours('TP')
        if planned <= 0:
            return 0.0
        return round((self.tp_completed / planned) * 100, 2) if planned > 0 else 0.0

    def total_progress(self):
        """Calculate total progress percentage"""
        total_planned = (
            self.get_planned_hours('CM') +
            self.get_planned_hours('TD') +
            self.get_planned_hours('TP')
        )
        if total_planned <= 0:
            return 0.0
        total_completed = self.cm_completed + self.td_completed + self.tp_completed
        return round((total_completed / total_planned) * 100, 2) if total_planned > 0 else 0.0

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
