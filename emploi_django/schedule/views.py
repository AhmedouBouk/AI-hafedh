from django.shortcuts import render, get_object_or_404, redirect
from django.views.generic import ListView
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.exceptions import ObjectDoesNotExist
import json
from .models import Course, Professor, Room, CourseAssignment, TimeSlot, Department, Semester
from django.shortcuts import get_object_or_404

def plan_view(request, dept_id, semester_id):
    """View for managing the schedule plan"""
    department = get_object_or_404(Department, id=dept_id)
    semester = get_object_or_404(Semester, id=semester_id)
    
    # Store in session
    request.session['department_id'] = dept_id
    request.session['semester_id'] = semester_id
    
    context = {
        'days': TimeSlot.DAYS,
        'periods': TimeSlot.PERIODS,
        'weeks': range(1, 18),
        'dept_id': dept_id,
        'semester_id': semester_id,
        'department': department,
        'semester': semester,
    }
    return render(request, 'schedule/plan.html', context)

class CourseListView(ListView):
    """
    List view for courses, now filtered by department and semester
    """
    model = Course
    template_name = 'schedule/database.html'
    context_object_name = 'courses'

    def get_queryset(self):
        """
        Override queryset to filter by department and semester
        """
        dept_id = self.kwargs.get('dept_id')
        semester_id = self.kwargs.get('semester_id')
        
        if not dept_id or not semester_id:
            # If no department or semester specified, return an empty queryset
            return Course.objects.none()
        
        # Filtrer les cours via les TimeSlots
        return Course.objects.filter(
            courseassignment__timeslot__department_id=dept_id,
            courseassignment__timeslot__semester_id=semester_id
        ).distinct()

    def get_context_data(self, **kwargs):
        """
        Add department and semester to context
        """
        context = super().get_context_data(**kwargs)
        
        dept_id = self.kwargs.get('dept_id')
        semester_id = self.kwargs.get('semester_id')
        
        context['department'] = get_object_or_404(Department, id=dept_id)
        context['semester'] = get_object_or_404(Semester, id=semester_id)
        
        return context

# API Views
def get_courses(request):
    """Get all courses"""
    courses = Course.objects.all()
    data = [{
        'code': course.code,
        'title': course.title
    } for course in courses]
    return JsonResponse(data, safe=False)

@csrf_exempt
def get_course_info(request, code):
    """Get, update, or delete course information"""
    try:
        if request.method == 'GET':
            course = Course.objects.get(pk=code)
            assignments = CourseAssignment.objects.filter(course=course)
            data = {
                'code': course.code,
                'title': course.title,
                'credits': course.credits,
                'cm_hours': course.cm_hours,
                'td_hours': course.td_hours,
                'tp_hours': course.tp_hours,
                'professors': {
                    'CM': assignments.filter(type='CM').first().professor.id if assignments.filter(type='CM').exists() else None,
                    'TD': assignments.filter(type='TD').first().professor.id if assignments.filter(type='TD').exists() else None,
                    'TP': assignments.filter(type='TP').first().professor.id if assignments.filter(type='TP').exists() else None,
                },
                'rooms': {
                    'CM': assignments.filter(type='CM').first().room.id if assignments.filter(type='CM').exists() and assignments.filter(type='CM').first().room else None,
                    'TD': assignments.filter(type='TD').first().room.id if assignments.filter(type='TD').exists() and assignments.filter(type='TD').first().room else None,
                    'TP': assignments.filter(type='TP').first().room.id if assignments.filter(type='TP').exists() and assignments.filter(type='TP').first().room else None,
                }
            }
            return JsonResponse(data)
            
        elif request.method == 'POST' or request.method == 'PUT':
            data = json.loads(request.body)
            course, created = Course.objects.update_or_create(
                code=code,
                defaults={
                    'title': data['title'],
                    'credits': data['credits'],
                    'cm_hours': data['cm_hours'],
                    'td_hours': data['td_hours'],
                    'tp_hours': data['tp_hours'],
                }
            )
            
            # Update assignments
            for type_key in ['CM', 'TD', 'TP']:
                if data['professors'].get(type_key):
                    professor = Professor.objects.get(id=data['professors'][type_key])
                    room = Room.objects.get(id=data['rooms'][type_key]) if data['rooms'].get(type_key) else None
                    CourseAssignment.objects.update_or_create(
                        course=course,
                        type=type_key,
                        defaults={
                            'professor': professor,
                            'room': room
                        }
                    )
            
            return JsonResponse({'status': 'success'})
            
        elif request.method == 'DELETE':
            course = Course.objects.get(pk=code)
            course.delete()
            return JsonResponse({'status': 'success'})
            
    except ObjectDoesNotExist:
        return JsonResponse({'error': 'Course not found.'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def get_professors(request):
    """Get all professors"""
    professors = Professor.objects.all()
    data = [{
        'id': prof.id,
        'name': prof.name
    } for prof in professors]
    return JsonResponse(data, safe=False)

def get_rooms(request):
    """Get all rooms"""
    rooms = Room.objects.all()
    data = [{
        'id': room.id,
        'number': room.number,
        'type': room.type
    } for room in rooms]
    return JsonResponse(data, safe=False)

def get_schedule(request, week):
    """Get schedule for a specific week"""
    slots = TimeSlot.objects.filter(week=week)
    data = [{
        'day': slot.day,
        'period': slot.period,
        'course_code': slot.course_assignment.course.code,
        'type': slot.course_assignment.type,
        'professor': slot.course_assignment.professor.name,
        'room': slot.course_assignment.room.number if slot.course_assignment.room else None
    } for slot in slots]
    return JsonResponse(data, safe=False)

def get_all_plan(request):
    """Get plan for all weeks"""
    slots = TimeSlot.objects.all()
    data = [{
        'week': slot.week,
        'day': slot.day,
        'period': slot.period,
        'course_code': slot.course_assignment.course.code,
        'type': slot.course_assignment.type
    } for slot in slots]
    return JsonResponse(data, safe=False)

@csrf_exempt
def get_plan(request, week):
    """Get plan for a specific week"""
    slots = TimeSlot.objects.filter(week=week)
    data = [{
        'day': slot.day,
        'period': slot.period,
        'course_code': slot.course_assignment.course.code,
        'type': slot.course_assignment.type
    } for slot in slots]
    return JsonResponse(data, safe=False)

@csrf_exempt
def save_plan(request):
    """Save schedule plan and update progress with department/semester isolation"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            plan = data['plan']
            department_id = data.get('department_id')
            semester_id = data.get('semester_id')

            # Validate required parameters
            if not department_id or not semester_id:
                return JsonResponse({'error': 'Department and semester IDs required'}, status=400)

            slots_by_week = {}
            affected_courses = set()

            # Validate department/semester existence
            department = Department.objects.get(id=department_id)
            semester = Semester.objects.get(id=semester_id)

            # Group slots by week
            for item in plan:
                week = item['week']
                slots_by_week.setdefault(week, []).append(item)
                affected_courses.add(item['course_code'])

            # Process slots for each week
            for week, items in slots_by_week.items():
                # Delete existing slots for this week+department+semester
                TimeSlot.objects.filter(
                    week=week,
                    department=department,
                    semester=semester
                ).delete()

                # Create new slots
                for item in items:
                    try:
                        course = Course.objects.get(
                            code=item['course_code'],
                            department=department,
                            semester=semester
                        )
                        assignment = CourseAssignment.objects.get(
                            course=course,
                            type=item['type']
                        )
                        
                        TimeSlot.objects.create(
                            week=week,
                            day=item['day'],
                            period=item['period'],
                            course_assignment=assignment,
                            department=department,
                            semester=semester
                        )

                    except Exception as e:
                        return JsonResponse({'error': f"Invalid data: {str(e)}"}, status=400)

            # Update course progress
            for course_code in affected_courses:
                try:
                    course = Course.objects.get(
                        code=course_code,
                        department=department,
                        semester=semester
                    )
                    course.update_completed_hours()
                except Course.DoesNotExist:
                    print(f"Course {course_code} not found in {department.name}/{semester.number}")

            return JsonResponse({'status': 'success'})

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON data'}, status=400)
        except Department.DoesNotExist:
            return JsonResponse({'error': 'Invalid department ID'}, status=404)
        except Semester.DoesNotExist:
            return JsonResponse({'error': 'Invalid semester ID'}, status=404)
        except Exception as e:
            print(f"Server error: {str(e)}")
            return JsonResponse({'error': 'Internal server error'}, status=500)

    return JsonResponse({'error': 'Invalid request method'}, status=405)

@csrf_exempt
def add_time_slot(request):
    """
    API view to add a time slot to the schedule
    """
    if request.method == 'POST':
        try:
            # Extract data from request
            slot = request.POST.get('slot')
            course_code = request.POST.get('course_code')
            course_type = request.POST.get('course_type')
            professor_id = request.POST.get('professor_id')
            room_id = request.POST.get('room_id')
            department_id = request.POST.get('department_id')
            semester_id = request.POST.get('semester_id')
            week = request.POST.get('week')

            # Validate required fields
            if not all([slot, course_code, course_type, professor_id, room_id, department_id, semester_id, week]):
                return JsonResponse({'status': 'error', 'message': 'Tous les champs sont requis'})

            # Retrieve related objects
            course = Course.objects.get(code=course_code)
            professor = Professor.objects.get(id=professor_id)
            room = Room.objects.get(id=room_id)
            department = Department.objects.get(id=department_id)
            semester = Semester.objects.get(id=semester_id)

            # Create course assignment
            course_assignment, created = CourseAssignment.objects.get_or_create(
                course=course,
                professor=professor,
                type=course_type,
                room=room
            )

            # Parse slot details
            day, period = slot.split('_')

            # Create time slot
            time_slot, slot_created = TimeSlot.objects.get_or_create(
                day=day,
                period=period,
                week=week,
                course_assignment=course_assignment,
                department=department,
                semester=semester
            )

            # Update course completed hours
            course.update_completed_hours()

            return JsonResponse({
                'status': 'success', 
                'message': 'Créneau ajouté avec succès',
                'slot_id': time_slot.id
            })

        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)})

    return JsonResponse({'status': 'error', 'message': 'Méthode non autorisée'})

@csrf_exempt
def update_course(request):
    try:
        data = json.loads(request.body)
        code = data.get('code')
        updates = data.get('updates', {})
        
        course = Course.objects.get(code=code)
        
        # Update each field
        for field, value in updates.items():
            if hasattr(course, field):
                setattr(course, field, value)
        
        course.save()
        
        return JsonResponse({
            'success': True,
            'message': 'Course updated successfully'
        })
    except ObjectDoesNotExist:
        return JsonResponse({'error': 'Course not found.'}, status=404)
    except Exception as e:
        return JsonResponse({
            'success': False,
            'message': str(e)
        }, status=400)

@csrf_exempt
def delete_course(request):
    """Delete a course"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body) if request.body else request.POST
            code = data.get('code')
            
            print(f"Attempting to delete course {code}")  # Debug print
            
            if not code:
                return JsonResponse({
                    'success': False,
                    'message': 'Course code is required'
                })
            
            try:
                course = Course.objects.get(code=code)
                course_name = str(course)  # Save course info before deletion
                course.delete()
                
                print(f"Successfully deleted course {code}")  # Debug print
                
                return JsonResponse({
                    'success': True,
                    'message': f'Course {course_name} deleted successfully'
                })
            except ObjectDoesNotExist:
                return JsonResponse({
                    'success': False,
                    'message': f'Course {code} not found'
                })
            except Exception as e:
                print(f"Error deleting course: {str(e)}")  # Debug print
                return JsonResponse({
                    'success': False,
                    'message': str(e)
                })
        except json.JSONDecodeError:
            return JsonResponse({
                'success': False,
                'message': 'Invalid JSON data'
            })

def debug_course_values(request):
    courses = Course.objects.all()
    course_data = [{'code': course.code, 'cm_completed': course.cm_completed, 'td_completed': course.td_completed, 'tp_completed': course.tp_completed} for course in courses]
    return JsonResponse(course_data, safe=False)

from django.shortcuts import render, get_object_or_404
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from .models import Course
import logging

logger = logging.getLogger(__name__)

def bilan_view(request, dept_id, semester_id):
    """
    View for displaying the course progress with strict department and semester isolation
    """
    try:
        department = Department.objects.get(id=dept_id)
        semester = Semester.objects.get(id=semester_id)
        courses = Course.objects.filter(department=department, semester=semester)
        for course in courses:
            course.total_progress_value = course.total_progress()
        context = {
            'courses': courses,
            'total_progress': [course.total_progress_value for course in courses],
            'department': department,
            'semester': semester
        }
        return render(request, 'schedule/bilan.html', context)
    except Exception as e:
        logger.error(f"Error in bilan_view: {str(e)}")
        return render(request, 'schedule/bilan.html', {
            'courses': [],
            'error_message': "Une erreur s'est produite lors du chargement des données.",
            'department': None,
            'semester': None
        })

@csrf_exempt
def update_bilan(request):
    """Update course completion values"""
    if request.method != 'POST':
        return JsonResponse({'error': 'Method not allowed'}, status=405)
    
    try:
        data = json.loads(request.body)
        course_code = data.get('course_code')
        field = data.get('field')
        value = data.get('value')

        # Validate required fields
        if not all([course_code, field, value]):
            return JsonResponse({'error': 'Missing required fields'}, status=400)

        # Validate field name
        if field not in ['cm_completed', 'td_completed', 'tp_completed']:
            return JsonResponse({'error': 'Invalid field name'}, status=400)

        # Validate value is a positive integer
        try:
            value = int(value)
            if value < 0:
                raise ValueError("Value must be positive")
        except ValueError as e:
            return JsonResponse({'error': str(e)}, status=400)

        # Get and update course
        course = Course.objects.get(code=course_code)
        
        # Validate against planned hours
        planned_hours = getattr(course, field.replace('completed', 'hours'))
        if value > planned_hours:
            return JsonResponse({
                'error': f'Les heures réalisées ({value}) ne peuvent pas dépasser les heures planifiées ({planned_hours})'
            }, status=400)

        # Update the field
        setattr(course, field, value)
        course.save()

        # Return updated progress values
        response_data = {
            'status': 'success',
            'progress': {
                'cm': course.progress_cm(),
                'td': course.progress_td(),
                'tp': course.progress_tp(),
                'total': course.total_progress()
            }
        }
        return JsonResponse(response_data)

    except ObjectDoesNotExist:
        return JsonResponse({'error': 'Course not found.'}, status=404)
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON data'}, status=400)
    except Exception as e:
        logger.error(f"Error in update_bilan: {str(e)}")
        return JsonResponse({'error': 'Server error'}, status=500)

@csrf_exempt

def add_course(request, dept_id, semester_id):
    """
    Ajoute un nouveau cours avec toutes les associations
    """
    if request.method == 'POST':
        try:
            department = get_object_or_404(Department, id=dept_id)
            semester = get_object_or_404(Semester, id=semester_id)
            data = request.POST.dict()

            # Validation des champs obligatoires
            required_fields = ['code', 'title', 'credits', 'cm_hours', 'td_hours', 'tp_hours']
            if missing := [f for f in required_fields if not data.get(f)]:
                return JsonResponse({
                    'status': 'error',
                    'error': f'Champs requis manquants: {", ".join(missing)}'
                }, status=400)

            # Vérification unicité code cours
            if Course.objects.filter(
                code=data['code'],
                department=department,
                semester=semester
            ).exists():
                return JsonResponse({
                    'status': 'error',
                    'error': f'Le code {data["code"]} existe déjà pour ce département/semestre'
                }, status=400)

            # Création du cours
            course = Course.objects.create(
                code=data['code'],
                title=data['title'],
                credits=int(data['credits']),
                cm_hours=int(data['cm_hours']),
                td_hours=int(data['td_hours']),
                tp_hours=int(data['tp_hours']),
                coefficient=int(data.get('coefficient', 0)),
                department=department,
                semester=semester
            )

            # Gestion des associations
            assignments = {
                'CM': {
                    'prof': data.get('cm_professor'),
                    'room': data.get('cm_room')
                },
                'TD': {
                    'prof': data.get('td_professor'),
                    'room': data.get('td_room')
                },
                'TP': {
                    'prof': data.get('tp_professor'),
                    'room': data.get('tp_room')
                }
            }

            for type_assignment, values in assignments.items():
                if values['prof']:
                    try:
                        professor = Professor.objects.get(id=values['prof'])
                        room = Room.objects.get(id=values['room']) if values['room'] else None
                        
                        CourseAssignment.objects.create(
                            course=course,
                            type=type_assignment,
                            professor=professor,
                            room=room,
                            department=department,
                            semester=semester
                        )
                    except Exception as e:
                        return JsonResponse({
                            'status': 'error',
                            'error': f'Erreur {type_assignment}: {str(e)}'
                        }, status=400)

            return JsonResponse({
                'status': 'success',
                'course': {
                    'code': course.code,
                    'title': course.title,
                    'assignments': {
                        'CM': course.get_cm_assignment().professor.name if course.get_cm_assignment() else None,
                        'TD': course.get_td_assignment().professor.name if course.get_td_assignment() else None,
                        'TP': course.get_tp_assignment().professor.name if course.get_tp_assignment() else None
                    }
                }
            })

        except Exception as e:
            return JsonResponse({
                'status': 'error',
                'error': f'Erreur serveur: {str(e)}'
            }, status=500)

    return JsonResponse({
        'status': 'error',
        'error': 'Méthode non autorisée'
    }, status=405)
def course_list_view(request, dept_id, semester_id):
    """
    List courses for a specific department and semester
    """
    department = get_object_or_404(Department, id=dept_id)
    semester = get_object_or_404(Semester, id=semester_id)
    
    courses = Course.objects.filter(
        department=department, 
        semester=semester
    )
    
    return render(request, 'schedule/database.html', {
        'courses': courses,
        'department': department,
        'semester': semester
    })

def create_course_assignment(request):
    """
    Create a course assignment with department and semester constraints
    """
    if request.method == 'POST':
        try:
            # Get department and semester from form
            department_id = request.POST.get('department')
            semester_id = request.POST.get('semester')
            
            department = Department.objects.get(id=department_id)
            semester = Semester.objects.get(id=semester_id)
            
            course_assignment = CourseAssignment.objects.create(
                course_id=request.POST.get('course'),
                professor_id=request.POST.get('professor'),
                type=request.POST.get('type'),
                room_id=request.POST.get('room'),
                department=department,
                semester=semester
            )
            
            return JsonResponse({
                'status': 'success', 
                'message': 'Course assignment created successfully',
                'assignment_id': course_assignment.id
            })
        except Exception as e:
            return JsonResponse({
                'status': 'error', 
                'message': str(e)
            }, status=400)

def add_time_slot(request):
    """
    Add a time slot with department and semester constraints
    """
    if request.method == 'POST':
        try:
            # Get department and semester from form
            department_id = request.POST.get('department')
            semester_id = request.POST.get('semester')
            
            department = Department.objects.get(id=department_id)
            semester = Semester.objects.get(id=semester_id)
            
            time_slot = TimeSlot.objects.create(
                day=request.POST.get('day'),
                period=request.POST.get('period'),
                week=request.POST.get('week'),
                course_assignment_id=request.POST.get('course_assignment'),
                department=department,
                semester=semester
            )
            
            return JsonResponse({
                'status': 'success', 
                'message': 'Time slot added successfully',
                'time_slot_id': time_slot.id
            })
        except Exception as e:
            return JsonResponse({
                'status': 'error', 
                'message': str(e)
            }, status=400)

def department_selection(request):
    """
    View for selecting department and semester
    """
    departments = Department.objects.all()
    
    if request.method == 'POST':
        dept_id = request.POST.get('department')
        semester_id = request.POST.get('semester')
        
        if dept_id and semester_id:
            return redirect('schedule:base', dept_id=dept_id, semester_id=semester_id)
    
    return render(request, 'schedule/selection.html', {
        'departments': departments
    })

def get_semesters(request, department_id):
    """
    API view to get semesters for a specific department
    """
    department = Department.objects.get(id=department_id)
    semesters = Semester.objects.filter(department=department).values('id', 'number')
    return JsonResponse(list(semesters), safe=False)

def schedule_view(request, dept_id, semester_id):
    """
    View for displaying schedule with strict department and semester isolation
    """
    department = get_object_or_404(Department, id=dept_id)
    semester = get_object_or_404(Semester, id=semester_id)
    
    # Stocker en session
    request.session['department_id'] = dept_id
    request.session['semester_id'] = semester_id
    
    # Récupérer les assignations de cours pour ce département et semestre
    course_assignments = CourseAssignment.objects.filter(
        department_id=dept_id, 
        semester_id=semester_id
    )
    
    # Récupérer les créneaux horaires
    time_slots = TimeSlot.objects.filter(
        department_id=dept_id, 
        semester_id=semester_id
    ).select_related(
        'course_assignment', 
        'course_assignment__course', 
        'course_assignment__professor'
    ).order_by('week', 'day', 'period')
    
    context = {
        'department': department,
        'semester': semester,
        'dept_id': dept_id,
        'semester_id': semester_id,
        'days': TimeSlot.DAYS,
        'periods': TimeSlot.PERIODS,
        'time_slots': time_slots,
        'weeks': range(1, 18)  # Ajustez selon vos besoins
    }
    
    return render(request, 'schedule/schedule.html', context)

def plan_view(request, dept_id, semester_id):
    """
    View for displaying plan with strict department and semester isolation
    """
    department = get_object_or_404(Department, id=dept_id)
    semester = get_object_or_404(Semester, id=semester_id)
    
    # Stocker en session
    request.session['department_id'] = dept_id
    request.session['semester_id'] = semester_id
    
    # Récupérer les assignations de cours
    course_assignments = CourseAssignment.objects.filter(
        department_id=dept_id, 
        semester_id=semester_id
    )
    
    # Récupérer les créneaux horaires
    time_slots = TimeSlot.objects.filter(
        department_id=dept_id, 
        semester_id=semester_id
    ).select_related(
        'course_assignment', 
        'course_assignment__course', 
        'course_assignment__professor'
    ).order_by('week', 'day', 'period')
    
    context = {
        'days': TimeSlot.DAYS,
        'periods': TimeSlot.PERIODS,
        'weeks': range(1, 18),
        'dept_id': dept_id,
        'semester_id': semester_id,
        'department': department,
        'semester': semester,
        'time_slots': time_slots,
    }
    return render(request, 'schedule/plan.html', context)

def bilan_view(request, dept_id, semester_id):
    """
    View for displaying the course progress with strict department and semester isolation
    """
    department = get_object_or_404(Department, id=dept_id)
    semester = get_object_or_404(Semester, id=semester_id)
    
    # Stocker en session
    request.session['department_id'] = dept_id
    request.session['semester_id'] = semester_id
    
    # Récupérer les assignations de cours
    course_assignments = CourseAssignment.objects.filter(
        department_id=dept_id, 
        semester_id=semester_id
    )
    
    # Récupérer les cours via les assignations de cours
    courses = Course.objects.filter(
        courseassignment__department_id=dept_id,
        courseassignment__semester_id=semester_id
    ).distinct()
    
    context = {
        'courses': courses,
        'department': department,
        'semester': semester,
        'dept_id': dept_id,
        'semester_id': semester_id
    }
    return render(request, 'schedule/Bilan.html', context)
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from .models import Course, TimeSlot
@csrf_exempt  # À remplacer par un décorateur CSRF approprié en production
def add_course(request, dept_id, semester_id):
    if request.method == 'POST':
        try:
            # Validation des données
            code = request.POST.get('code')
            if Course.objects.filter(code=code).exists():
                return JsonResponse({
                    'status': 'error',
                    'error': f'Le code {code} existe déjà'
                }, status=400)

            # Création du cours
            course = Course.objects.create(
                code=code,
                title=request.POST.get('title'),
                credits=request.POST.get('credits'),
                cm_hours=request.POST.get('cm_hours'),
                td_hours=request.POST.get('td_hours'),
                tp_hours=request.POST.get('tp_hours'),
                cm_professor=request.POST.get('cm_professor', ''),
                td_professor=request.POST.get('td_professor', ''),
                tp_professor=request.POST.get('tp_professor', ''),
                cm_room=request.POST.get('cm_room', ''),
                tp_room=request.POST.get('tp_room', '')
            )

            # Redirection après succès
            return redirect('database', dept_id=dept_id, semester_id=semester_id)

        except Exception as e:
            return JsonResponse({'status': 'error', 'error': str(e)}, status=500)
    
    return JsonResponse({'status': 'error', 'error': 'Méthode non autorisée'}, status=405)



def database_view(request, dept_id, semester_id):
    """
    View for displaying database with strict department and semester isolation
    """
    department = get_object_or_404(Department, id=dept_id)
    semester = get_object_or_404(Semester, id=semester_id)
    
    # Stocker en session
    request.session['department_id'] = dept_id
    request.session['semester_id'] = semester_id
    
    # Filtrer les cours via les TimeSlots
    courses = Course.objects.filter(
        courseassignment__timeslot__department_id=dept_id,
        courseassignment__timeslot__semester_id=semester_id
    ).distinct()
    
    # Récupérer les assignations de cours
    course_assignments = CourseAssignment.objects.filter(
        department_id=dept_id, 
        semester_id=semester_id
    )
    
    context = {
        'courses': courses,
        'course_assignments': course_assignments,
        'department': department,
        'semester': semester,
        'dept_id': dept_id,
        'semester_id': semester_id
    }
    
    return render(request, 'schedule/database.html', context)

def get_courses(request, dept_id, semester_id):
    courses = Course.objects.filter(
        timeslot__department_id=dept_id,
        timeslot__semester_id=semester_id
    ).distinct()
    
    data = [{
        'code': course.code,
        'title': course.title,
        'cm_professor': course.cm_professor,
        'tp_room': course.tp_room
    } for course in courses]
    
    return JsonResponse(data, safe=False)
def get_all_plan(request):
    """Get plan for all weeks"""
    slots = TimeSlot.objects.all()
    data = [{
        'week': slot.week,
        'day': slot.day,
        'period': slot.period,
        'course_code': slot.course_assignment.course.code,
        'type': slot.course_assignment.type
    } for slot in slots]
    return JsonResponse(data, safe=False)
@csrf_exempt
def save_plan(request):
    """Save schedule plan"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            plan = data['plan']
            
            print(f"Received plan data: {plan}")
            
            # Group slots by week for batch processing
            slots_by_week = {}
            for item in plan:
                week = item['week']
                if week not in slots_by_week:
                    slots_by_week[week] = []
                slots_by_week[week].append(item)
            
            # Process each week's slots
            for week, items in slots_by_week.items():
                print(f"Processing week {week}")
                # Delete existing slots for this week
                TimeSlot.objects.filter(week=week).delete()
                
                # Create new slots for this week
                for item in items:
                    try:
                        print(f"Processing item: {item}")
                        course_code = item.get('course_code')
                        assignment_type = item.get('type')

                        if not course_code:
                            raise ValueError('Course code is missing')
                        if not assignment_type:
                            raise ValueError('Assignment type is missing')

                        course = Course.objects.get(code=course_code)
                        assignment = CourseAssignment.objects.get(
                            course=course,
                            type=assignment_type
                        )
                        
                        # Create the time slot
                        TimeSlot.objects.create(
                            week=item['week'],
                            day=item['day'],
                            period=item['period'],
                            course_assignment=assignment
                        )
                    except (Course.DoesNotExist, CourseAssignment.DoesNotExist) as e:
                        print(f"Error finding course or assignment: {e}")
                        return JsonResponse({
                            'error': f'Could not find course or assignment: {str(e)}. Course code: {course_code}, Type: {assignment_type}'
                        }, status=400)
                    except Exception as e:
                        print(f"Error saving time slot: {e}")
                        return JsonResponse({
                            'error': f'Error saving time slot: {str(e)}. Data: {item}'
                        }, status=500)
            
            return JsonResponse({'status': 'success'})
        except KeyError as e:
            print(f"Missing required field: {e}")
            return JsonResponse({
                'error': f'Missing required field: {str(e)}'
            }, status=400)
        except json.JSONDecodeError as e:
            print(f"Invalid JSON data: {e}")
            return JsonResponse({
                'error': 'Invalid JSON data'
            }, status=400)
        except Exception as e:
            print(f"Unexpected error: {e}")
            return JsonResponse({
                'error': f'Unexpected error: {str(e)}'
            }, status=500)
    
    return JsonResponse({'error': 'Invalid request method'}, status=405)

@csrf_exempt
def get_plan(request, week):
    """Get plan for a specific week"""
    slots = TimeSlot.objects.filter(week=week)
    data = [{
        'day': slot.day,
        'period': slot.period,
        'course_code': slot.course_assignment.course.code,
        'type': slot.course_assignment.type
    } for slot in slots]
    return JsonResponse(data, safe=False)

def base_view(request, dept_id, semester_id):
    """
    View for base template with department and semester context
    """
    department = get_object_or_404(Department, id=dept_id)
    semester = get_object_or_404(Semester, id=semester_id)
    
    context = {
        'department': department,
        'semester': semester,
        'dept_id': dept_id,
        'semester_id': semester_id
    }
    
    return render(request, 'schedule/base.html', context)