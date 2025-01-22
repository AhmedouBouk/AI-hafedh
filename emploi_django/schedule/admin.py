from django.contrib import admin
from .models import Department, Semester ,Course

# Enregistrement basique
admin.site.register(Department)
admin.site.register(Semester)

admin.site.register(Course)

# Register your models here.
