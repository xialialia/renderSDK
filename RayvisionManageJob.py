#!/usr/bin/env python
# -*- coding:utf-8 -*-

"""
Task Module.
"""

class RayvisionManageJob(object):
    def __init__(self, api_obj):
        self._api_obj = api_obj
        
    def _get_rendering_list(self, page_size=20, page_num=1):
        """
        Get rendering list.
        """
        return self._api_obj._get_job_list(page_size, page_num)
        
    def _search_job(self, search_word="", page_size=20, page_num=1):
        """
        Search job by searchKeyword.
        """
        return self._api_obj._get_job_list(page_size, page_num, search_word)
        
    def _get_job_status(self, job_id, page_size=20, page_num=1):
        """
        Get single job's rendering status.
        :param str job_id:
        """
        
        is_find_it = False
        
        return_data = self._search_job(search_word=str(job_id), page_size=page_size, page_num=page_num)
        page_count = int(return_data.get('pageCount'))  # number of pages，总页数
        page_num = int(return_data.get('pageNum'))  # page number，页码
        total = int(return_data.get('total'))  # number of the result items，item的数量
        items = return_data.get('items')  # items list
        
        if total >= 1:  # so page_count>=1
            for item in items:
                if int(job_id) == item.get('id'):
                    return_data['items'] = item
                    is_find_it = True
                    break
                    
            if not is_find_it:
                if 1 <= page_num < page_count:
                    # for page_num_new in range(2, page_count+1):
                    page_num += 1
                    return self._get_job_status(job_id, page_size, page_num)
                else:
                    return_data['items'] = []
            
        return return_data
                
        
    def _full_speed_job(self):
        """
        Job operation: full speed render the other frames after checked the priority frames
        """
        pass
    
    def _start_job(self):
        """
        Job operation: start job.
        """
        pass
    
    def _stop_job(self):
        """
        Job operation: stop job. The job can still start.
        """
        pass
        
    def _abandon_job(self):
        """
        Job operation: abandon job. The job can not still start.
        """
        pass
    
    def _recommit_fail_frame_in_job(self):
        """
        Job operation: recommit failure frames.
        """
        pass
    
    def _delete_job(self):
        """
        Job operation: delete job.
        """
        pass
        
        
    def _re_render_frame(self):
        """
        Frame operation: re-render frame.
        """
        pass
    
    def _stop_frame(self):
        """
        Frame operation: stop frame.
        """
        pass
        
    def _start_frame(self):
        """
        Frame operation: start frame.
        """
        pass
        

        