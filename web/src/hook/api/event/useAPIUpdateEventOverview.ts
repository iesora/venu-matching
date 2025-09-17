import { useMutation, UseMutationOptions } from "react-query";
import { axiosInstance } from "@/utils/url";
import { eventOverviewURL } from "@/utils/url/event";
import { Event } from "@/type";
import { AxiosError } from "axios";
import { jsonHeader } from "@/utils/url/header";

export interface UpdateEventOverviewRequest {
  eventId: number;
  title: string;
  description: string;
  startDate: Date;
  endDate: Date;
}

const updateEventOverview = async (body: UpdateEventOverviewRequest) => {
  const headers = await jsonHeader;
  const response = await axiosInstance.patch(eventOverviewURL, body, {
    headers,
  });
  return response.data;
};

export const useAPIUpdateEventOverview = (
  mutationOptions?: UseMutationOptions<
    Event,
    AxiosError,
    UpdateEventOverviewRequest
  >
) => {
  return useMutation<Event, AxiosError, UpdateEventOverviewRequest>(
    updateEventOverview,
    mutationOptions
  );
};
