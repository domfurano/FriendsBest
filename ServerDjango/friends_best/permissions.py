from rest_framework import permissions

class Owner(permissions.BasePermission):
	
	def has_object_permission(self, request, view, obj):
		
		return obj.user == request.user
		
		
class OwnerOrReadOnly(permissions.BasePermission):

    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed to any request,
        # so we'll always allow GET, HEAD or OPTIONS requests.
        if request.method in permissions.SAFE_METHODS:
            return True

        # Write permissions are only allowed to the owner of the snippet.
        return obj.user == request.user

class OwnerOrReadOnlyPin(permissions.BasePermission):

    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed to any request,
        # so we'll always allow GET, HEAD or OPTIONS requests.
        if request.method in permissions.SAFE_METHODS:
            return True

        # Write permissions are only allowed to the owner of the snippet.
        return obj.query.user == request.user

class OwnerCanReadDelete(permissions.BasePermission):
    
    def has_object_permission(self, request, view, obj):
        
        # Allow anyone to get
        if request.method in ("GET", "OPTIONS", "HEAD"):
            return True
            
        # Allow the owner to delete
        if request.method == "DELETE":
            return obj.user == request.user
        
        # Everyone/anything else, no access
        return False


# This is eventaully a method that will limit read access to the owner or friend.
# We still need to determine the scope of recommendations.
class IsOwnerOrFriend(permissions.BasePermission):
	
	def has_object_permission(self, request, view, obj):
		
		return True