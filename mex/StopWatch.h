/*
 * Copyright © CASIA 2015-2016.
 *
 * Authors: Jiaxiang Wu
 * E-mail: jiaxiang.wu.90@gmail.com
 */

#ifndef MEX_STOPWATCH_H_
#define MEX_STOPWATCH_H_

#include <ctime>

class StopWatch {
 public:
  // initialize the stop-watch
  StopWatch(void);
  // resume the stop-watch
  void Resume(void);
  // pause the stop-watch
  void Pause(void);
  // get the elapsed time
  float GetTime(void);

 private:
  // timestamp of the starting point
  time_t timeBeg_;
  // timestamp of the ending point
  time_t timeEnd_;
  // elapsed time (in seconds)
  float timeElps_;
};

// implementation of member functions

StopWatch::StopWatch(void) {
  timeBeg_ = clock();
  timeEnd_ = clock();
  timeElps_ = 0.0;
}

void StopWatch::Resume(void) {
  timeBeg_ = clock();  // record the beginning time
}

void StopWatch::Pause(void) {
  timeEnd_ = clock();  // record the ending time
  timeElps_ += static_cast<float>(timeEnd_ - timeBeg_) / CLOCKS_PER_SEC;
}

float StopWatch::GetTime(void) {
  return timeElps_;
}

#endif  // MEX_STOPWATCH_H_
