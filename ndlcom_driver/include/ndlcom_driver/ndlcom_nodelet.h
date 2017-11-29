
 // -------------------------------------------------------------------------------- 
 // Copyright (c) 2017 CNR-ITIA <iras@itia.cnr.it>
 // All rights reserved.
 //
 // Redistribution and use in source and binary forms, with or without
 // modification, are permitted provided that the following conditions are met:
 //
 // 1. Redistributions of source code must retain the above copyright notice,
 // this list of conditions and the following disclaimer.
 // 2. Redistributions in binary form must reproduce the above copyright
 // notice, this list of conditions and the following disclaimer in the
 // documentation and/or other materials provided with the distribution.
 // 3. Neither the name of mosquitto nor the names of its
 // contributors may be used to endorse or promote products derived from
 // this software without specific prior written permission.
 //
 //
 // THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 // AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 // IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 // ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 // LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 // CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 // SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 // INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 // CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 // ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 // POSSIBILITY OF SUCH DAMAGE.
 // -------------------------------------------------------------------------------- 

#ifndef __NDLCOM_NODELET__
#define __NDLCOM_NODELET__

#include <nodelet/nodelet.h>
#include <ndlcom_driver/ndlcom_utils.h>
#include <iostream>
#include <fstream> 
#include <boost/graph/graph_concepts.hpp>

namespace ndlcom_ros{
  


class NdlcomDriverNodelet : public nodelet::Nodelet
{
public:
  virtual void onInit();

protected:
  std::thread m_read_thread;                                  // NOTE: std thread is moveable!
  std::thread m_write_thread;
  std::thread m_publish_thread;
  std::thread m_ros_thread;
  ndlcom_ros::NdlcomDriver m_ndlcom_driver;

  ~NdlcomDriverNodelet();
};





}

# endif