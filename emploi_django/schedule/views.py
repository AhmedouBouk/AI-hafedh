from django.shortcuts import render, redirect
from django.views.generic import ListView
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.exceptions import ObjectDoesNotExist
import json
import logging
from .models import Course, Professor, Room, CourseAssignment, TimeSlot, Soutenance, EncadrementMilitaire

logger = logging.getLogger(__name__)

def bilan_view(request):
    if request.method == 'POST':
        try:
            data = request.POST
            new_course = Course.objects.create(
                code=data['code'],
                title=data['title'],
                credits=int(data['credits']),
                cm_hours=int(data['cm_hours']),
                td_hours=int(data['td_hours']),
                tp_hours=int(data['tp_hours']),
                cm_completed=0,
                td_completed=0,
                tp_completed=0,
                exam_completed=0,
                devoir_completed=0
            )
            return redirect('bilan')
        except Exception as e:
            logger.error(f"Error creating course: {str(e)}")
            return JsonResponse({'error': str(e)}, status=400)

    # Get all courses for display
    courses = Course.objects.all().order_by('code')
    professors = Professor.objects.all()
    rooms = Room.objects.all()
    
    # Calculer les totaux
    total_cm_hours = sum(course.cm_hours for course in courses)
    total_td_hours = sum(course.td_hours for course in courses)
    total_tp_hours = sum(course.tp_hours for course in courses)
    
    total_cm_completed = sum(course.cm_completed for course in courses)
    total_td_completed = sum(course.td_completed for course in courses)
    total_tp_completed = sum(course.tp_completed for course in courses)
    
    # Calculer les pourcentages globaux
    total_cm_progress = (total_cm_completed / total_cm_hours * 100) if total_cm_hours > 0 else 0
    total_td_progress = (total_td_completed / total_td_hours * 100) if total_td_hours > 0 else 0
    total_tp_progress = (total_tp_completed / total_tp_hours * 100) if total_tp_hours > 0 else 0
    
    # Calculer le total global
    total_hours = total_cm_hours + total_td_hours + total_tp_hours
    total_completed = total_cm_completed + total_td_completed + total_tp_completed
    total_progress = (total_completed / total_hours * 100) if total_hours > 0 else 0
    
    courses_data = []
    for course in courses:
        course_data = {
            'code': course.code,
            'title': course.title,
            'credits': course.credits,
            'cm_hours': course.cm_hours,
            'td_hours': course.td_hours,
            'tp_hours': course.tp_hours,
            'cm_completed': course.cm_completed,
            'td_completed': course.td_completed,
            'tp_completed': course.tp_completed,
            'exam_completed': course.exam_completed,
            'devoir_completed': course.devoir_completed,
            'total_hours': course.get_total_hours(),
            'total_completed': course.get_total_completed(),
            'progress_cm': course.progress_cm(),
            'progress_td': course.progress_td(),
            'progress_tp': course.progress_tp(),
            'progress_exam': course.progress_exam(),
            'progress_devoir': course.progress_devoir(),
            'total_progress': course.total_progress()
        }
        courses_data.append(course_data)
    
    # Get soutenances and encadrements
    soutenances = Soutenance.objects.all().order_by('date', 'heure_debut')
    encadrements = EncadrementMilitaire.objects.all().order_by('date', 'heure_debut')
    
    context = {
        'courses': courses_data,
        'professors': professors,
        'rooms': rooms,
        'soutenances': soutenances,
        'encadrements': encadrements,
        'totals': {
            'cm': {
                'hours': total_cm_hours,
                'completed': total_cm_completed,
                'progress': round(total_cm_progress, 1)
            },
            'td': {
                'hours': total_td_hours,
                'completed': total_td_completed,
                'progress': round(total_td_progress, 1)
            },
            'tp': {
                'hours': total_tp_hours,
                'completed': total_tp_completed,
                'progress': round(total_tp_progress, 1)
            },
            'global': {
                'hours': total_hours,
                'completed': total_completed,
                'progress': round(total_progress, 1)
            }
        }
    }
    return render(request, 'schedule/bilan.html', context)

@csrf_exempt
def update_bilan(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            course_code = data.get('course_code')
            field = data.get('field')
            value = int(data.get('value', 0))

            try:
                course = Course.objects.get(code=course_code)
            except Course.DoesNotExist:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Cours non trouvé'
                }, status=404)

            # Valider que la valeur ne dépasse pas les heures planifiées
            if field == 'cm_completed' and value > course.cm_hours:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Les heures CM complétées ne peuvent pas dépasser les heures planifiées'
                }, status=400)
            elif field == 'td_completed' and value > course.td_hours:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Les heures TD complétées ne peuvent pas dépasser les heures planifiées'
                }, status=400)
            elif field == 'tp_completed' and value > course.tp_hours:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Les heures TP complétées ne peuvent pas dépasser les heures planifiées'
                }, status=400)
            elif field == 'exam_completed' and value > course.exam_hours:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Les heures d\'examen complétées ne peuvent pas dépasser les heures planifiées'
                }, status=400)
            elif field == 'devoir_completed' and value > course.devoir_hours:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Les heures de devoir complétées ne peuvent pas dépasser les heures planifiées'
                }, status=400)

            # Mettre à jour la valeur
            setattr(course, field, value)
            course.save()

            # Retourner les nouvelles valeurs de progression
            return JsonResponse({
                'status': 'success',
                'message': 'Mise à jour réussie',
                'data': {
                    'progress_cm': course.progress_cm(),
                    'progress_td': course.progress_td(),
                    'progress_tp': course.progress_tp(),
                    'progress_exam': course.progress_exam(),
                    'progress_devoir': course.progress_devoir(),
                    'total_progress': course.total_progress()
                }
            })
        except ValueError:
            return JsonResponse({
                'status': 'error',
                'message': 'Valeur invalide'
            }, status=400)
        except Exception as e:
            return JsonResponse({
                'status': 'error',
                'message': str(e)
            }, status=500)
    
    return JsonResponse({
        'status': 'error',
        'message': 'Méthode non autorisée'
    }, status=405)

@csrf_exempt
def delete_course(request):
    if request.method == 'POST':
        try:
            course_id = request.POST.get('course_id')
            if not course_id:
                return JsonResponse({
                    'status': 'error',
                    'message': 'ID du cours non fourni'
                }, status=400)

            try:
                course = Course.objects.get(id=course_id)
            except Course.DoesNotExist:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Cours non trouvé'
                }, status=404)
            
            # La suppression des affectations est maintenant gérée dans le modèle Course
            course.delete()
            
            return JsonResponse({
                'status': 'success',
                'message': 'Cours supprimé avec succès'
            })
        except Exception as e:
            return JsonResponse({
                'status': 'error',
                'message': f'Erreur lors de la suppression : {str(e)}'
            }, status=500)
            
    return JsonResponse({
        'status': 'error',
        'message': 'Méthode non autorisée'
    }, status=405)

@csrf_exempt
def add_course(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            
            # Vérifier si le code existe déjà
            if Course.objects.filter(code=data['code']).exists():
                return JsonResponse({
                    'status': 'error',
                    'message': f"Un cours avec le code {data['code']} existe déjà"
                }, status=400)
            
            # Create the course
            new_course = Course.objects.create(
                code=data['code'],
                title=data['title'],
                credits=int(data['credits']),
                cm_hours=int(data['cm_hours']),
                td_hours=int(data['td_hours']),
                tp_hours=int(data['tp_hours']),
                cm_completed=0,
                td_completed=0,
                tp_completed=0,
                exam_completed=0,
                devoir_completed=0
            )
            
            # Add professor assignments
            if data.get('cm_professor'):
                CourseAssignment.objects.create(
                    course=new_course,
                    professor_id=data['cm_professor'],
                    type='CM'
                )
            else:
                CourseAssignment.objects.create(
                    course=new_course,
                    type='CM'
                )
            
            if data.get('td_professor'):
                CourseAssignment.objects.create(
                    course=new_course,
                    professor_id=data['td_professor'],
                    type='TD'
                )
            else:
                CourseAssignment.objects.create(
                    course=new_course,
                    type='TD'
                )
                
            if data.get('tp_professor'):
                CourseAssignment.objects.create(
                    course=new_course,
                    professor_id=data['tp_professor'],
                    type='TP'
                )
            else:
                CourseAssignment.objects.create(
                    course=new_course,
                    type='TP'
                )
            
            # Add room assignments if provided
            if data.get('cm_room'):
                assignment = CourseAssignment.objects.get(course=new_course, type='CM')
                assignment.room_id = data['cm_room']
                assignment.save()
                
            if data.get('tp_room'):
                assignment = CourseAssignment.objects.get(course=new_course, type='TP')
                assignment.room_id = data['tp_room']
                assignment.save()
            
            return JsonResponse({
                'status': 'success',
                'message': 'Cours ajouté avec succès',
                'course': {
                    'code': new_course.code,
                    'title': new_course.title,
                    'credits': new_course.credits,
                    'cm_hours': new_course.cm_hours,
                    'td_hours': new_course.td_hours,
                    'tp_hours': new_course.tp_hours
                }
            })
        except Exception as e:
            return JsonResponse({
                'status': 'error',
                'message': str(e)
            }, status=400)
    return JsonResponse({
        'status': 'error',
        'message': 'Méthode non autorisée'
    }, status=405)

@csrf_exempt
def professors_view(request):
    professors = Professor.objects.all()
    return render(request, 'schedule/professors.html', {'professors': professors})

@csrf_exempt
def add_professor(request):
    if request.method == 'POST':
        try:
            name = request.POST.get('name')
            if not name:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Le nom est requis'
                }, status=400)
            
            professor = Professor.objects.create(name=name)
            return JsonResponse({
                'status': 'success',
                'message': 'Professeur ajouté avec succès',
                'professor': {
                    'id': professor.id,
                    'name': professor.name
                }
            })
        except Exception as e:
            return JsonResponse({
                'status': 'error',
                'message': str(e)
            }, status=400)
    return JsonResponse({
        'status': 'error',
        'message': 'Méthode non autorisée'
    }, status=405)

@csrf_exempt
def update_professor(request):
    if request.method == 'POST':
        try:
            professor_id = request.POST.get('professor_id')
            field = request.POST.get('field')
            value = request.POST.get('value')
            
            professor = Professor.objects.get(id=professor_id)
            original_value = getattr(professor, field)
            
            setattr(professor, field, value)
            professor.save()
            
            return JsonResponse({
                'status': 'success',
                'message': 'Professeur mis à jour avec succès'
            })
        except Professor.DoesNotExist:
            return JsonResponse({
                'status': 'error',
                'message': 'Professeur non trouvé',
                'original_value': original_value
            }, status=404)
        except Exception as e:
            return JsonResponse({
                'status': 'error',
                'message': str(e),
                'original_value': original_value
            }, status=400)
    return JsonResponse({
        'status': 'error',
        'message': 'Méthode non autorisée'
    }, status=405)

@csrf_exempt
def delete_professor(request):
    if request.method == 'POST':
        try:
            professor_id = request.POST.get('professor_id')
            professor = Professor.objects.get(id=professor_id)
            professor.delete()
            return JsonResponse({
                'status': 'success',
                'message': 'Professeur supprimé avec succès'
            })
        except Professor.DoesNotExist:
            return JsonResponse({
                'status': 'error',
                'message': 'Professeur non trouvé'
            }, status=404)
        except Exception as e:
            return JsonResponse({
                'status': 'error',
                'message': str(e)
            }, status=500)
    return JsonResponse({
        'status': 'error',
        'message': 'Méthode non autorisée'
    }, status=405)

@csrf_exempt
def rooms_view(request):
    rooms = Room.objects.all()
    return render(request, 'schedule/rooms.html', {'rooms': rooms})

@csrf_exempt
def add_room(request):
    if request.method == 'POST':
        try:
            number = request.POST.get('number')
            room_type = request.POST.get('type')
            
            if not number or not room_type:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Le numéro et le type sont requis'
                }, status=400)
            
            room = Room.objects.create(
                number=number,
                type=room_type
            )
            return JsonResponse({
                'status': 'success',
                'message': 'Salle ajoutée avec succès',
                'room': {
                    'id': room.id,
                    'number': room.number,
                    'type': room.type
                }
            })
        except Exception as e:
            return JsonResponse({
                'status': 'error',
                'message': str(e)
            }, status=400)
    return JsonResponse({
        'status': 'error',
        'message': 'Méthode non autorisée'
    }, status=405)

@csrf_exempt
def update_room(request):
    if request.method == 'POST':
        try:
            room_id = request.POST.get('room_id')
            field = request.POST.get('field')
            value = request.POST.get('value')
            
            room = Room.objects.get(id=room_id)
            original_value = getattr(room, field)
            
            setattr(room, field, value)
            room.save()
            
            return JsonResponse({
                'status': 'success',
                'message': 'Salle mise à jour avec succès'
            })
        except Room.DoesNotExist:
            return JsonResponse({
                'status': 'error',
                'message': 'Salle non trouvée',
                'original_value': original_value
            }, status=404)
        except Exception as e:
            return JsonResponse({
                'status': 'error',
                'message': str(e),
                'original_value': original_value
            }, status=400)
    return JsonResponse({
        'status': 'error',
        'message': 'Méthode non autorisée'
    }, status=405)

@csrf_exempt
def delete_room(request):
    if request.method == 'POST':
        try:
            room_id = request.POST.get('room_id')
            room = Room.objects.get(id=room_id)
            room.delete()
            return JsonResponse({
                'status': 'success',
                'message': 'Salle supprimée avec succès'
            })
        except Room.DoesNotExist:
            return JsonResponse({
                'status': 'error',
                'message': 'Salle non trouvée'
            }, status=404)
        except Exception as e:
            return JsonResponse({
                'status': 'error',
                'message': str(e)
            }, status=500)
    return JsonResponse({
        'status': 'error',
        'message': 'Méthode non autorisée'
    }, status=405)

def schedule_view(request):
    """View for displaying the weekly schedule"""
    context = {
        'days': TimeSlot.DAYS,
        'periods': TimeSlot.PERIODS,
        'weeks': range(1, 18),  # S1 to S17
    }
    return render(request, 'schedule/schedule.html', context)

def plan_view(request):
    """View for managing the schedule plan"""
    context = {
        'days': TimeSlot.DAYS,
        'periods': TimeSlot.PERIODS,
        'weeks': range(1, 18),
    }
    return render(request, 'schedule/plan.html', context)

class CourseListView(ListView):
    """View for displaying and managing the course database"""
    model = Course
    template_name = 'schedule/database.html'
    context_object_name = 'courses'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['professors'] = Professor.objects.all()
        context['rooms'] = Room.objects.all()
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
        return JsonResponse({'error': 'Course not found'}, status=404)
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
def update_course(request):
    if request.method == 'POST':
        try:
            course_id = request.POST.get('course_id')
            field = request.POST.get('field')
            value = request.POST.get('value')
            
            course = Course.objects.get(id=course_id)
            original_value = getattr(course, field)
            
            # Handle professor and room updates
            if field in ['cm_professor', 'td_professor', 'tp_professor']:
                assignment_type = field.split('_')[0].upper()
                CourseAssignment.objects.filter(course=course, type=assignment_type).delete()
                if value:
                    CourseAssignment.objects.create(
                        course=course,
                        professor_id=value,
                        type=assignment_type
                    )
                return JsonResponse({'status': 'success'})
                
            elif field in ['cm_room', 'tp_room']:
                assignment_type = field.split('_')[0].upper()
                CourseAssignment.objects.filter(course=course, type=assignment_type).delete()
                if value:
                    CourseAssignment.objects.create(
                        course=course,
                        room_id=value,
                        type=assignment_type
                    )
                return JsonResponse({'status': 'success'})
            
            # Handle numeric fields
            elif field in ['credits', 'cm_hours', 'td_hours', 'tp_hours']:
                value = int(value)
            
            setattr(course, field, value)
            course.save()
            
            return JsonResponse({
                'status': 'success',
                'original_value': original_value
            })
            
        except Course.DoesNotExist:
            return JsonResponse({
                'status': 'error',
                'error': 'Course not found'
            }, status=404)
        except Exception as e:
            return JsonResponse({
                'status': 'error',
                'error': str(e),
                'original_value': original_value
            }, status=400)
            
    return JsonResponse({
        'status': 'error',
        'error': 'Invalid request method'
    }, status=405)

def debug_course_values(request):
    courses = Course.objects.all()
    course_data = [{'code': course.code, 'cm_completed': course.cm_completed, 'td_completed': course.td_completed, 'tp_completed': course.tp_completed, 'exam_completed': course.exam_completed, 'devoir_completed': course.devoir_completed} for course in courses]
    return JsonResponse(course_data, safe=False)