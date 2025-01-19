from django.shortcuts import render
from django.views.generic import ListView
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.exceptions import ObjectDoesNotExist
import json
from .models import Course, Professor, Room, CourseAssignment, TimeSlot

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
    """Save schedule plan and update progress"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            plan = data['plan']
            
            print(f"Received plan data: {plan}")
            
            # Group slots by week for batch processing
            slots_by_week = {}
            affected_courses = set()  # Track which courses are affected
            
            for item in plan:
                week = item['week']
                if week not in slots_by_week:
                    slots_by_week[week] = []
                slots_by_week[week].append(item)
                # Track affected course
                affected_courses.add(item['course_code'])
            
            # Process each week's slots
            for week, items in slots_by_week.items():
                print(f"Processing week {week}")
                # Delete existing slots for this week
                TimeSlot.objects.filter(week=week).delete()
                
                # Create new slots for this week
                for item in items:
                    try:
                        print(f"Processing item: {item}")
                        course = Course.objects.get(code=item['course_code'])
                        assignment = CourseAssignment.objects.get(
                            course=course,
                            type=item['type']
                        )
                        
                        # Create the time slot
                        TimeSlot.objects.create(
                            week=item['week'],
                            day=item['day'],
                            period=item['period'],
                            course_assignment=assignment
                        )
                    except Exception as e:
                        print(f"Error processing item: {str(e)}")
                        return JsonResponse({'error': str(e)}, status=500)
            
            # Update progress for all affected courses
            for course_code in affected_courses:
                try:
                    course = Course.objects.get(code=course_code)
                    course.update_completed_hours()
                except Course.DoesNotExist:
                    print(f"Course {course_code} not found")
                except Exception as e:
                    print(f"Error updating progress for {course_code}: {str(e)}")
            
            return JsonResponse({'status': 'success'})
            
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON data'}, status=400)
        except Exception as e:
            print(f"Error saving plan: {str(e)}")
            return JsonResponse({'error': str(e)}, status=500)
    
    return JsonResponse({'error': 'Invalid request method'}, status=405)

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
    except Course.DoesNotExist:
        return JsonResponse({
            'success': False,
            'message': 'Course not found'
        }, status=404)
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
            except Course.DoesNotExist:
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

def bilan_view(request):
    """View for displaying the course progress"""
    try:
        courses = Course.objects.all().order_by('code')
        for course in courses:
            course.total_progress_value = course.total_progress()
        context = {
            'courses': courses,
            'total_progress': [course.total_progress_value for course in courses]
        }
        return render(request, 'schedule/Bilan.html', context)
    except Exception as e:
        logger.error(f"Error in bilan_view: {str(e)}")
        return render(request, 'schedule/Bilan.html', {
            'courses': [],
            'error_message': "Une erreur s'est produite lors du chargement des données."
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

    except Course.DoesNotExist:
        return JsonResponse({'error': 'Course not found'}, status=404)
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON data'}, status=400)
    except Exception as e:
        logger.error(f"Error in update_bilan: {str(e)}")
        return JsonResponse({'error': 'Server error'}, status=500)

@csrf_exempt
def add_course(request):
    """Add a new course to the database"""
    if request.method == 'POST':
        try:
            print("Received data:", request.POST)  # Debug print
            
            # Extract course data
            course_data = {
                'code': request.POST.get('code'),
                'title': request.POST.get('title'),
                'credits': int(request.POST.get('credits', 0)),
                'cm_hours': int(request.POST.get('cm_hours', 0)),
                'td_hours': int(request.POST.get('td_hours', 0)),
                'tp_hours': int(request.POST.get('tp_hours', 0)),
            }
            
            print("Processed course data:", course_data)  # Debug print
            
            # Validate required fields
            required_fields = ['code', 'title', 'credits', 'cm_hours', 'td_hours', 'tp_hours']
            missing_fields = [field for field in required_fields if not course_data.get(field)]
            
            if missing_fields:
                return JsonResponse({
                    'status': 'error',
                    'error': f'Missing required fields: {", ".join(missing_fields)}'
                }, status=400)
            
            # Create course
            course = Course.objects.create(**course_data)
            print(f"Created course: {course.code}")  # Debug print
            
            # Handle professor assignments
            for type_code in ['CM', 'TD', 'TP']:
                professor_name = request.POST.get(f'{type_code.lower()}_professor')
                if professor_name:
                    print(f"Creating {type_code} professor: {professor_name}")  # Debug print
                    professor, _ = Professor.objects.get_or_create(name=professor_name)
                    CourseAssignment.objects.create(
                        course=course,
                        professor=professor,
                        type=type_code
                    )
            
            # Handle room assignments
            cm_room = request.POST.get('cm_room')
            tp_room = request.POST.get('tp_room')
            
            if cm_room:
                print(f"Creating CM room: {cm_room}")  # Debug print
                room, _ = Room.objects.get_or_create(number=cm_room)
                assignments = CourseAssignment.objects.filter(course=course, type='CM')
                if assignments.exists():
                    assignments.update(room=room)
            
            if tp_room:
                print(f"Creating TP room: {tp_room}")  # Debug print
                room, _ = Room.objects.get_or_create(number=tp_room)
                assignments = CourseAssignment.objects.filter(course=course, type='TP')
                if assignments.exists():
                    assignments.update(room=room)
            
            # Get professor names for response
            cm_professor = CourseAssignment.objects.filter(course=course, type='CM').first()
            td_professor = CourseAssignment.objects.filter(course=course, type='TD').first()
            tp_professor = CourseAssignment.objects.filter(course=course, type='TP').first()
            
            # Return success response with course data
            response_data = {
                'status': 'success',
                'course': {
                    'code': course.code,
                    'title': course.title,
                    'credits': course.credits,
                    'cm_hours': course.cm_hours,
                    'td_hours': course.td_hours,
                    'tp_hours': course.tp_hours,
                    'vht': course.vht if hasattr(course, 'vht') else '',
                    'cm_professor': cm_professor.professor.name if cm_professor else '',
                    'td_professor': td_professor.professor.name if td_professor else '',
                    'tp_professor': tp_professor.professor.name if tp_professor else '',
                    'cm_room': cm_room or '',
                    'tp_room': tp_room or '',
                }
            }
            
            print("Sending response:", response_data)  # Debug print
            return JsonResponse(response_data)
            
        except ValueError as e:
            return JsonResponse({
                'status': 'error',
                'error': f'Invalid value: {str(e)}'
            }, status=400)
        except Exception as e:
            print(f"Error in add_course: {str(e)}")  # Debug print
            return JsonResponse({
                'status': 'error',
                'error': str(e)
            }, status=500)
    
    return JsonResponse({
        'status': 'error',
        'error': 'Invalid request method'
    }, status=405)