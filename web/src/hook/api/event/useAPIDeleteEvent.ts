import { AxiosError } from "axios";
import { useMutation, UseMutationOptions } from "react-query";
import { axiosInstance } from "@/utils/url";
import { jsonHeader } from "@/utils/url/header";
import { eventURL } from "@/utils/url/event";
import { Event } from "@/type";

const deleteEvent = async (id: number) => {
  const headers = await jsonHeader;
  const response = await axiosInstance.delete(`${eventURL}/${id}`, {
    headers,
  });
  return response.data;
};

export const useAPIDeleteEvent = (
  mutationOptions?: UseMutationOptions<Event, AxiosError, number>
) => {
  return useMutation<Event, AxiosError, number>(deleteEvent, mutationOptions);
};
