from django.db import models

# Create your models here.

class Course(models.Model):
    code = models.CharField(max_length=10, primary_key=True)
    title = models.CharField(max_length=100)
    credits = models.IntegerField(default=0)
    
    # Heures planifiées
    cm_hours = models.IntegerField(default=0)
    td_hours = models.IntegerField(default=0)
    tp_hours = models.IntegerField(default=0)
    exam_hours = models.IntegerField(default=0)  # Heures d'examen
    devoir_hours = models.IntegerField(default=0)  # Heures de devoir
    
    # Heures complétées
    cm_completed = models.IntegerField(default=0)
    td_completed = models.IntegerField(default=0)
    tp_completed = models.IntegerField(default=0)
    exam_completed = models.IntegerField(default=0)  # Examens complétés
    devoir_completed = models.IntegerField(default=0)  # Devoirs complétés

    class Meta:
        ordering = ['code']

    def __str__(self):
        return f"{self.code} - {self.title}"

    def get_total_hours(self):
        return self.cm_hours + self.td_hours + self.tp_hours

    def get_total_completed(self):
        return self.cm_completed + self.td_completed + self.tp_completed + self.exam_completed + self.devoir_completed

    def progress_cm(self):
        if self.cm_hours == 0:
            return 0
        return min(100, (self.cm_completed / self.cm_hours * 100))

    def progress_td(self):
        if self.td_hours == 0:
            return 0
        return min(100, (self.td_completed / self.td_hours * 100))

    def progress_tp(self):
        if self.tp_hours == 0:
            return 0
        return min(100, (self.tp_completed / self.tp_hours * 100))

    def progress_exam(self):
        if self.exam_hours == 0:
            return 0
        return min(100, (self.exam_completed / self.exam_hours * 100))

    def progress_devoir(self):
        if self.devoir_hours == 0:
            return 0
        return min(100, (self.devoir_completed / self.devoir_hours * 100))

    def total_progress(self):
        total_hours = self.get_total_hours()
        if total_hours == 0:
            return 0
        return min(100, (self.get_total_completed() / (total_hours + self.exam_hours + self.devoir_hours) * 100))

    def save(self, *args, **kwargs):
        # Validation pour s'assurer que les heures complétées ne dépassent pas les heures planifiées
        if self.cm_completed > self.cm_hours:
            raise ValueError("Les heures CM complétées ne peuvent pas dépasser les heures planifiées")
        if self.td_completed > self.td_hours:
            raise ValueError("Les heures TD complétées ne peuvent pas dépasser les heures planifiées")
        if self.tp_completed > self.tp_hours:
            raise ValueError("Les heures TP complétées ne peuvent pas dépasser les heures planifiées")
        if self.exam_completed > self.exam_hours:
            raise ValueError("Les heures d'examen complétées ne peuvent pas dépasser les heures planifiées")
        if self.devoir_completed > self.devoir_hours:
            raise ValueError("Les heures de devoir complétées ne peuvent pas dépasser les heures planifiées")
        super().save(*args, **kwargs)

    def clean(self):
        """Valide que les heures complétées ne dépassent pas les heures planifiées"""
        from django.core.exceptions import ValidationError
        
        if self.cm_completed > self.cm_hours:
            raise ValidationError({'cm_completed': 'Les heures CM complétées ne peuvent pas dépasser les heures planifiées'})
        
        if self.td_completed > self.td_hours:
            raise ValidationError({'td_completed': 'Les heures TD complétées ne peuvent pas dépasser les heures planifiées'})
            
        if self.tp_completed > self.tp_hours:
            raise ValidationError({'tp_completed': 'Les heures TP complétées ne peuvent pas dépasser les heures planifiées'})

        if self.exam_completed > self.exam_hours:
            raise ValidationError({'exam_completed': 'Les heures d\'examen complétées ne peuvent pas dépasser les heures planifiées'})

        if self.devoir_completed > self.devoir_hours:
            raise ValidationError({'devoir_completed': 'Les heures de devoir complétées ne peuvent pas dépasser les heures planifiées'})

    def delete(self, *args, **kwargs):
        # Supprimer d'abord les affectations
        self.courseassignment_set.all().delete()
        # Puis supprimer le cours
        super().delete(*args, **kwargs)

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
    professor = models.ForeignKey(Professor, on_delete=models.SET_NULL, null=True, blank=True)
    room = models.ForeignKey(Room, on_delete=models.SET_NULL, null=True, blank=True)
    type = models.CharField(max_length=2, choices=[('CM', 'CM'), ('TD', 'TD'), ('TP', 'TP')])

    class Meta:
        unique_together = [('course', 'type')]

    def __str__(self):
        parts = [f"{self.course.code} - {self.type}"]
        if self.professor:
            parts.append(f"Prof: {self.professor.name}")
        if self.room:
            parts.append(f"Salle: {self.room.number}")
        return " | ".join(parts)

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

class Soutenance(models.Model):
    date = models.DateField()
    heure_debut = models.TimeField()
    heure_fin = models.TimeField()
    salle = models.ForeignKey('Room', on_delete=models.SET_NULL, null=True)
    jury = models.ManyToManyField('Professor')
    description = models.TextField(blank=True)
    
    def __str__(self):
        return f"Soutenance du {self.date} de {self.heure_debut} à {self.heure_fin}"

class EncadrementMilitaire(models.Model):
    date = models.DateField()
    heure_debut = models.TimeField()
    heure_fin = models.TimeField()
    lieu = models.CharField(max_length=100)
    responsable = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    
    def __str__(self):
        return f"Encadrement militaire du {self.date} de {self.heure_debut} à {self.heure_fin}"
