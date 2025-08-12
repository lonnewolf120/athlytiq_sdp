from fastapi import Request,Response
from starlette.middleware.base import BaseHTTPMiddleware
import time 
from collections import defaultdict
from typing import Dict 

class LoggerMiddleware(BaseHTTPMiddleware):
    def __init__(self, app):
        super().__init__(app)
        self.rate_limit_records: Dict[str,float] = defaultdict(float)
    
    async def log_message(self,message:str):
        print(message)
    
    async def dispatch(self, request:Request, call_next):
       client_ip = request.client.host 
       current_time = time.time()
    #    if current_time - self.rate_limit_records[client_ip] < 100: ##100 request per second limit
    #        return Response(content="Rate limit exceeded: 100 request per second is allowed",status_code=429)
       
       self.rate_limit_records[client_ip] = current_time
       
       ##async logging
       path = request.url.path 
       await self.log_message(f"Request to {path} from {client_ip}")
       
       ##process the request
       start_time = time.time()
       response = await call_next(request)
       process_time = time.time()-start_time
       
       ##custom header
       custom_headers = {"X-Process-Time": str(process_time)}
       for header,value in custom_headers.items():
           response.headers.append(header,value)
       
       await self.log_message(f"Request to {path} from {client_ip} took {process_time} seconds") 
       return response  