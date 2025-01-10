# Generated by Django 5.1.4 on 2025-01-10 15:53

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Course',
            fields=[
                ('code', models.CharField(max_length=10, primary_key=True, serialize=False)),
                ('title', models.CharField(max_length=100)),
                ('credits', models.IntegerField()),
                ('cm_hours', models.IntegerField()),
                ('td_hours', models.IntegerField()),
                ('tp_hours', models.IntegerField()),
            ],
        ),
        migrations.CreateModel(
            name='Room',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('number', models.CharField(max_length=20)),
                ('type', models.CharField(max_length=20)),
            ],
        ),
        migrations.CreateModel(
            name='CourseAssignment',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('type', models.CharField(choices=[('CM', 'Cours Magistral'), ('TD', 'Travaux Dirigés'), ('TP', 'Travaux Pratiques')], max_length=2)),
                ('course', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='schedule.course')),
            ],
        ),
        migrations.CreateModel(
            name='Professor',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('courses', models.ManyToManyField(through='schedule.CourseAssignment', to='schedule.course')),
            ],
        ),
        migrations.AddField(
            model_name='courseassignment',
            name='professor',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='schedule.professor'),
        ),
        migrations.AddField(
            model_name='courseassignment',
            name='room',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to='schedule.room'),
        ),
        migrations.CreateModel(
            name='TimeSlot',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('day', models.CharField(choices=[('LUN', 'Lundi'), ('MAR', 'Mardi'), ('MER', 'Mercredi'), ('JEU', 'Jeudi'), ('VEN', 'Vendredi')], max_length=3)),
                ('period', models.CharField(choices=[('P1', '08h00 à 09h30'), ('P2', '09h45 à 11h15'), ('P3', '11h30 à 13h00'), ('P4', '15h10 à 16h40'), ('P5', '16h50 à 18h20')], max_length=2)),
                ('week', models.IntegerField()),
                ('course_assignment', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='schedule.courseassignment')),
            ],
            options={
                'unique_together': {('day', 'period', 'week')},
            },
        ),
    ]