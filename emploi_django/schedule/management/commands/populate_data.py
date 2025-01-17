from django.core.management.base import BaseCommand
from schedule.models import Course, Professor, Room, CourseAssignment

class Command(BaseCommand):
    help = 'Populate database with initial data'

    def handle(self, *args, **kwargs):
        # Create courses
        courses = [
            {
                'code': 'IRT31',
                'title': 'Programmation Python',
                'credits': 3,
                'cm_hours': 21,
                'td_hours': 10.5,
                'tp_hours': 10.5
            },
            {
                'code': 'IRT32',
                'title': 'Base de données',
                'credits': 3,
                'cm_hours': 21,
                'td_hours': 10.5,
                'tp_hours': 10.5
            },
            {
                'code': 'IRT33',
                'title': 'Réseaux',
                'credits': 3,
                'cm_hours': 21,
                'td_hours': 10.5,
                'tp_hours': 10.5
            }
        ]
        
        for course_data in courses:
            Course.objects.get_or_create(**course_data)
            self.stdout.write(f'Created course: {course_data["code"]}')

        # Create professors
        professors = [
            {'name': 'Dr. Smith'},
            {'name': 'Prof. Johnson'},
            {'name': 'Dr. Williams'}
        ]
        
        for prof_data in professors:
            Professor.objects.get_or_create(**prof_data)
            self.stdout.write(f'Created professor: {prof_data["name"]}')

        # Create rooms
        rooms = [
            {'number': 'A101', 'type': 'CM'},
            {'number': 'B201', 'type': 'TD'},
            {'number': 'C301', 'type': 'TP'}
        ]
        
        for room_data in rooms:
            Room.objects.get_or_create(**room_data)
            self.stdout.write(f'Created room: {room_data["number"]}')

        # Create course assignments
        assignments = [
            # Python course assignments
            {'course': Course.objects.get(code='IRT31'), 'professor': Professor.objects.get(name='Dr. Smith'), 'type': 'CM', 'room': Room.objects.get(number='A101')},
            {'course': Course.objects.get(code='IRT31'), 'professor': Professor.objects.get(name='Dr. Smith'), 'type': 'TD', 'room': Room.objects.get(number='B201')},
            {'course': Course.objects.get(code='IRT31'), 'professor': Professor.objects.get(name='Dr. Smith'), 'type': 'TP', 'room': Room.objects.get(number='C301')},
            
            # Database course assignments
            {'course': Course.objects.get(code='IRT32'), 'professor': Professor.objects.get(name='Prof. Johnson'), 'type': 'CM', 'room': Room.objects.get(number='A101')},
            {'course': Course.objects.get(code='IRT32'), 'professor': Professor.objects.get(name='Prof. Johnson'), 'type': 'TD', 'room': Room.objects.get(number='B201')},
            {'course': Course.objects.get(code='IRT32'), 'professor': Professor.objects.get(name='Prof. Johnson'), 'type': 'TP', 'room': Room.objects.get(number='C301')},
            
            # Networks course assignments
            {'course': Course.objects.get(code='IRT33'), 'professor': Professor.objects.get(name='Dr. Williams'), 'type': 'CM', 'room': Room.objects.get(number='A101')},
            {'course': Course.objects.get(code='IRT33'), 'professor': Professor.objects.get(name='Dr. Williams'), 'type': 'TD', 'room': Room.objects.get(number='B201')},
            {'course': Course.objects.get(code='IRT33'), 'professor': Professor.objects.get(name='Dr. Williams'), 'type': 'TP', 'room': Room.objects.get(number='C301')}
        ]
        
        for assignment_data in assignments:
            CourseAssignment.objects.get_or_create(**assignment_data)
            self.stdout.write(f'Created assignment: {assignment_data["course"].code} - {assignment_data["type"]}')

        self.stdout.write(self.style.SUCCESS('Successfully populated database'))
